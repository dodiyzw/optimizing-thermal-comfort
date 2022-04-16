#code written in julia
using JuMP
using CairoMakie
using Colors
using GLPK
using DataFrames
using CSV
using Statistics

my_blue = colorant"rgba(100,143,255,0.9)"
my_purple = colorant"rgba(120,94,240,0.9)"
my_pink = colorant"rgba(220,38,127,0.9)"
my_orange = colorant"rgba(254,97,0,0.9)"
my_yellow = colorant"rgba(255,176,0,0.9)"

struct result
    t26::Float64                #minutes using t26
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
    @variable(model, x1 >= 0)                               #x1 = t26
    @variable(model, x2 >= 0)                               #x2 = t25
    @variable(model, x3 >= 0)                               #x3 = t24
    @variable(model, x4 >= 0)                               #x4 = t23
    #defining constraints 
    @constraint(model, x1 + x2 + x3 + x4 == dur)            #duration to keep AC on       
    @constraint(model, x4 + x3 >= 2 * x2)                     #duration of using t24+t23 is \geq 2x duration of t25
    @constraint(model, x4 >= 1.5 * x3)                        #for better thermal comfort, duration of t23 >= 1.5*t24
    @constraint(model, x1 + x3 >= 1.5 * x4)                   #t26 + t24 >= 2*t23 to save cost
    @constraint(model, x1 >= 1.5 * x2)                        #t26 >= 1.5 t25 to save cost
    # @constraint(model, x4 + x3 == x1 + x2)
    #defining objective 
    @objective(
        model,
        Min,
        t_26_cost * x1 + t_25_cost * x2 + t_24_cost * x3 + t_23_cost * x4
    )
    optimize!(model)
    return result(
        value.(x1),
        value.(x2),
        value.(x3),
        value.(x4),
        dur,
        objective_value(model),
    )
end

filename = "dataset.csv"
df = DataFrame(CSV.File(filename))
df = dropmissing(df)
uniq_temp = unique!(df[:, :Temp]) |> vec
# df[isequal.(df[:, :Temp], 25), :]
# t_26 = df[(df.Temp.==26), :]
# t_25 = df[(df.Temp.==25), :]
# t_24 = df[(df.Temp.==24), :]
# t_23 = df[(df.Temp.==23), :]

t_26, t_25, t_24, t_23 = df[(df.Temp.==26), :],
df[(df.Temp.==25), :],
df[(df.Temp.==24), :],
df[(df.Temp.==23), :]

t_26_cost, t_25_cost, t_24_cost, t_23_cost =
    (t_26[:, :Initial] .- t_26[:, :Final]) ./ t_26[:, :Duration] |> mean,
    (t_25[:, :Initial] .- t_25[:, :Final]) ./ t_25[:, :Duration] |> mean,
    (t_24[:, :Initial] .- t_24[:, :Final]) ./ t_24[:, :Duration] |> mean,
    (t_23[:, :Initial] .- t_23[:, :Final]) ./ t_23[:, :Duration] |> mean

#a simple test for 60 minutes of use
lin_p(60)

#simulating for 30 days of aircond usage
ls = [lin_p(rand(30:30:300)) for _ = 1:30]
cum_cost = [ii.cost for ii in ls] |> cumsum
# cum_cost = cumsum(costs)

fig = Figure(resolution = (2000, 2000), font = "CMU Serif", fontsize = 20)
ax1 = Axis(
    fig[1, 1],
    xlabel = "Days",
    ylabel = " cost in SGD",
    textsize = 30,
    height = 500,
    width = 700,
)
scatter!(ax1, collect(1:30), cum_cost, color = my_purple)
hidedecorations!(ax1, ticklabels = false, label = false)
resize_to_layout!(fig)
fig
save("output/cost.png", fig)

#running 10 iterations
col = cgrad(:Dark2_5, 10, categorical = true)
lss = []
fig = Figure(resolution = (2000, 2000), font = "CMU Serif", fontsize = 20)
ax1 = Axis(
    fig[1, 1],
    xlabel = "Days",
    ylabel = " cost in SGD",
    textsize = 30,
    height = 500,
    width = 700,
)
for i = 1:10
    ls = [lin_p(rand(30:30:300)) for _ = 1:30]
    cum_cost = [ii.cost for ii in ls] |> cumsum
    push!(lss, cum_cost[end])
    scatter!(ax1, collect(1:30), cum_cost, markersize = 7, color = col[i])
    hidedecorations!(ax1, ticklabels = false, label = false)
end
resize_to_layout!(fig)
fig
save("output/sim.png", fig)

mean(lss)
std(lss)
maximum(lss)
minimum(lss)