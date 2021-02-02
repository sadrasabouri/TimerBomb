# TimerBomb
Timer Bomb Simulator - AVR

This Timer Bomb will start counting down from `00:01:00` to `00:00:00` and will be burst if one can't defuse it in this time.
Timer value will be shown on a 2*16 LCD - as shown in bellow snapshot -.

Bomb passcode will be inputted by a terminal box containing 4 char (and it's by the way `9697`), by pressing `Enter` key passcode will be checked if it's valid or not. If the passcode is valid bomb will be defused and LCD will show `Defused` and a green LED will be turned on showing that bomb has been refused. Otherwise LCD will show `88:88:88` and a red LED will be turned on as a sign of explosion.

<img src="https://github.com/sadrasabouri/TimerBomb/blob/main/Others/Shematics.png">

## Developers

* **Mohammad Qumi** [Mohammad Qumi](https://github.com/Mohammad-Qumi)
* **Sadra Sabouri** [Sadra Sabouri](https://github.com/sadrasabouri)
* **Mohammad Sina Hassan Nia** [Mohammad Sina Hassan Nia](https://github.com/sinahsnn)

## Technical Detail

End of each run will be ended to one of these bellow situations:

| Defused | Burst |
|:-------:|:-------:|
| <img width="435" height="204" src="https://github.com/sadrasabouri/TimerBomb/blob/main/Others/Defused.PNG"> | <img width="435" height="204" src="https://github.com/sadrasabouri/TimerBomb/blob/main/Others/Burst.PNG"> |

Here is a table which declares each registor and it's use in this code:

| Registor | Use |
|:-------:|:-------:|
| R16 | Is always 0 and used in delay functions |
| R17 | Used in delay loops |
| R18 | Used in delay loops |
| R19 | Used in delay loops |
| R20 | Tmp registor and buffer for sending data to LCD |
| R21 | First char of inputted code |
| R22 | Second char of inputted code |
| R23 | Third char of inputted code |
| R24 | Fourth char of inputted code |
| R25 | Terminal in buffer |
| R26 | LSM of timer seconds |
| R27 | MSB of timer seconds |
| R29 | Input terminal state |
