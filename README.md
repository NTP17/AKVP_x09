# AKVP x09, a 9-bit processor
Yes, you read it right. NINE bits, not EIGHT. I'm just doing what I was required to do.

This project is made in Intel® Quartus Prime Lite Edition, for DE10-Standard. It is possible, however, to modify the codes to fit any board you want.

Here are the requirements. All credit goes to Department of Electronics, Ho Chi Minh city University of Technology.

[Pre-Lab5_Digital_Design_Ver1.pdf](https://github.com/71-PTN/AKVP_x09/files/9043029/Pre-Lab5_Digital_Design_Ver1.pdf)

[Lab6_Digital_Design_Ver1.pdf](https://github.com/71-PTN/AKVP_x09/files/9043030/Lab6_Digital_Design_Ver1.pdf)

I have added a display register for outputting to three 7-segment displays, 3 bits each. It is obvious that base-8 or octal, must be used.

![Screenshot (1525)](https://user-images.githubusercontent.com/108677525/177245727-c6c37ab4-9825-4b49-9555-618d30e03db5.png)
## Complete instruction set
### Summary
*Note: Dashed (-) bit means "don't care".*
|Code|Operation|Meaning|Description|
|:---|:---|:---|:---|
|000xxxyyy|MV Rx, Ry|Rx <- [Ry]|Copy content of Ry to Rx.|
|001xxx---|MVI Rx|Rx <- mem[PC+1]|Fetch RAM data from address PC+1, then load into Rx.|
|010xxxyyy|ADD Rx, Ry|Rx <- [Rx] + [Ry]|Add contents of Rx and Ry together, then put the result back to Rx.| 
|011xxxyyy|SUB Rx, Ry|Rx <- [Rx] - [Ry]|Subtract content of Ry from Rx, then put the result back to Rx.|
|100xxxyyy|LD Rx, Ry|Rx <- mem[[Ry]]|Load data into Rx from the RAM address specified in Ry.|
|101xxxyyy|ST Rx, Ry|mem[Ry] <- [Rx]|Store data contained in Rx into RAM address found in Ry.|
|110xxxyyy |MVNZ Rx, Ry|if G != 0, Rx <- [Ry]|Perform *MV Rx, Ry* only when G register is not zero. Otherwise, do nothing.|
|111xxx---|OUT Rx|HEX[2..0] <- [Rx]|Output content of Rx to three 7-segment displays in octal (base-8).|
### Detailed
*Note: For better appearance, zeroes are replaced with blank cells.*

![image](https://user-images.githubusercontent.com/108677525/177464570-f6d6ca7c-4e22-41cd-b541-525dbe63bd61.png)
# The debugger, a.k.a. the visualizer
[The *debugger* folder](debugger/) have the exact same files as the root folder, plus some extra components to aid in outputting all register contents, RAM contents, and control signals to [DE10-Standard](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=1081)'s GPIOs. Since there are only 36 GPIO pins while the total number of outputs is 162 (13 x 9-bit registers + 29 control signals + 7 RAM address bits + 9 RAM content bits), I have to put together some external components to do the trick.

![20220701_120442](https://user-images.githubusercontent.com/108677525/177268555-39d3afd4-efff-4651-b15b-2cc7bbe3dd2d.jpg)

First off, the register contents. I soldered 117 LEDs into a 9 x 13 matrix, with 9 anodes each column connected, and 13 cathodes each row connected. An [inverted ring counter](debugger/ring_counter.vhd) loops through one row at time at super high speed, while the *when else* block at the end of the [top-level entity](debugger/debugger.vhd) determines which register will be outputted to the columns of each row.

![20220705_185734](https://user-images.githubusercontent.com/108677525/177323792-eae22fe4-1a1f-41e3-88c0-337c46572245.jpg)
![20220701_120513](https://user-images.githubusercontent.com/108677525/177270973-023c32ea-add5-446b-b040-0d55db353b76.jpg)

Outputting control signals and RAM stuff is slightly more complicated. The [parallel-to-serial converter](debugger/PISO.vhd) utilizes DE10-Standard's internal 50 MHz clock to continuously generate three lines of serial data: data input, shift clock, and output clock, which will then feed into respective inputs of one [74HC595](https://assets.nexperia.com/documents/data-sheet/74HC_HCT595.pdf) IC, which is chained together with more 74HC595's to turn the serial data back to parallel, forming a 3-to-29 converter for control signals, and 3-to-16 for RAM.
