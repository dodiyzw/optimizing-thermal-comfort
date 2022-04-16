#code written in julia
using JuMP
using CairoMakie
using Colors
using GLPK 

my_blue = colorant"rgba(100,143,255,0.9)"
my_purple = colorant"rgba(120,94,240,0.9)"
my_pink = colorant"rgba(220,38,127,0.9)"
my_orange = colorant"rgba(254,97,0,0.9)"
my_yellow = colorant"rgba(255,176,0,0.9)"

struct result
    t25::Float64                #minutes using t25
    t24::Float64                #minutes using t24
    t23::Float64                #minutes using t23
    duration::Float64           #duration
    cost::Float64               #total cost
end

function lin_p(dur)
    #create JuMP model. For linear programming, we can use the HiGHS optimizer 
    model = Model(GLPK.Optimizer)
    #create a set of decision variables 
    @variable(model, x1 >= 0)                               #x1 = t25
    @variable(model, x2 >= 0)                               #x2 = t24
    @variable(model, x3 >= 0)                               #x3 = t23
    #defining constraints 
    @constraint(model, x1 + x2 + x3 == dur)                 #duration to keep AC on       
    @constraint(model, x1 + x3 >= 2x2)                      #duration of using t25+t23 more than twice duration of t24
    @constraint(model, x3 >= 1.5x1)                         #for better thermal comfort, duration of t23 > 1.5*t25
    #defining objective 
    @objective(model, Min, 0.005x1 + 0.0033x2 + 0.0066x3)
    optimize!(model)
    return result(value.(x1), value.(x2), value.(x3), dur, objective_value(model))
end 


#initializing the system
ls = [lin_p(rand(30:30:300)) for _ = 1:30]
costs = [ii.cost for ii in ls]
cum_cost = cumsum(costs)

fig = Figure(resolution = (2000,2000), font = "CMU Serif", fontsize = 20)
ax1 = Axis(fig[1,1], xlabel = "Days", ylabel = " cost in SGD", textsize = 30, height = 500, width = 700)
scatter!(ax1, collect(1:30), cum_cost, color = my_purple)
hidedecorations!(ax1, ticklabels = false, label = false)
resize_to_layout!(fig)
fig