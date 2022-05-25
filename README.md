# optimizing-thermal-comfort

This project is interested in optimizing the cost of air-conditioning usage that would maximize thermal comfort. Thermal comfort refers to the idea of having an environment that feels comfortable to people's perception. Quality of sleep is intricately related to the thermal comfort a person experiences, and hence this project is interested in exploring how to optimizing the cost associated with providing thermal comfort with the use of air-conditioning. Setting the air-conditioner to different temperature provides different level of comfort, and each temperature comes with an associated cost.

This project will make use of linear programming to minimize the cost of air-conditioning usage while attempting to maximize thermal comfort.

Data on the associated cost of air-conditioning (AC) usage due to different temperatures were first collected by myself based on my own AC usage. I collected 33 days of data from my air-conditioning usage, varying the temperature from $23,24,25$ and $26$ $^{\circ}$ C. 


## Problem Formulation

My objective function is thus to minimize the cost of using all these temperature settings. My linear program can thus be expressed as:
<p align="center">$\textbf{min } z = 0.00306x_{1} + 0.00264x_{2} + 0.00292x_{3} + 0.00333x_{4}$</p>

subjected to 
<p align="center">
    $x_{1} + x_{2} + x_{3} + x_{4} = \textrm{dur} \qquad \textrm{total duration}$
</p> 

<p align="center">
  $x_{4} + x{3} \geq 2x_{2} \qquad \textrm{   constraint 2}$
</p>

<p align="center">
  $x_{1} + x_{3} \geq 1.5x_{4} \qquad \textrm{constraint 3}$
</p>

<p align="center">
  $x_{1} \geq 1.5x_{2} \quad \textrm{constraint 4}$
</p>

where the constants in the objective function refers to cost associated per $30$ minutes use of AC for each temperature setting. $x{1}$ corresponds to $23$
$^{\circ}$ C and so on.
## Multiple-simulation result from Linear Programming for cost over a month 
<p>
    <img src="output/sim.png?raw=true" width="800" height="600" />
</p>

### Limitation
First, **electricity tariff could be different** for different user depending on where users are from and which electricity vendor chosen. 

Secondly, I only have $3$ data points to obtain the unit cost of using t = $26$ $^{\circ}$ C, $12$ data points each  for t = $25$ $^{\circ}$ C and t = $24$ $^{\circ}$ C and $6$ data points for t = $23$ $^{\circ}$ C. To obtain a more reliable value for the cost per minute use of these temperature settings, **more data points would be desirable**.

Thirdly,  thermal comfort is a different experience for different people and hence these temperature settings might not be comfortable enough for other users. data from a greater range of temperature settings are required to make this study more representative.

Lastly, **thermal comfort is a complex area of study** that requires us to understand things such as heat capacity of a space or a person. Hence, the work of this project does not claim that temperature alone will account for a person's thermal comfort and one would also need to consider factors such as humidity.  
