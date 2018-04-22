# Prim's Algorithm in Alloy
An implementation of Prim's algorithm for finding the MST of a graph with provable correctness in Alloy.

Please view the **Analysis_Report.pdf** for detailed coverage of the project. For instructions on how to download and run the model, see below.

## Installation Instructions
1. Begin by installing Alloy. The downloadable JAR file can be found [here](http://alloytools.org/download.html) and is runnable on any machine with a working copy of Java.
2. Once the Alloy enviroment is installed, download the model of Prim's algorithm from [here](https://github.com/PaulWarnick21/Prims-Algorithm-Alloy/blob/master/Prims_Algorithm_Alloy.als).
3. Open Alloy by double clicking the JAR file, at the top there will be an option to open a file. Locate where you downloaded the file from the previous step and open it within the Alloy editor.
4. Once the file has been loaded in, at the very top (between Edit and Options) will be a drop down menu for Execute. Within that drop down menu select: *Check correct for 5 but 5 int, 10 Edge*. This will show that the model generates a **spanning tree**.
5. Finally, select the other execute option of: *Check smallest for 5 but 5 in, 10 Edge* to show the model generates the **minimum spanning tree**.

**Note: This final option is very robust and can take around 20 minutes to complete.**
