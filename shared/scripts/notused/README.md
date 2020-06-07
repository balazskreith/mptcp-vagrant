## Scenario 3

In this test scenario two sources of network traffic are used: one uses 2 subflows, 
and the other use 1 subflow. The first source uses two bottleneck links, out of which 
one is shared with the second source uses one subflow. To setup the testbed for this scenario run:
    
    ./setup.sh
    
After that, to perform tests, run:

    ./run.sh

As a result, you will have run_1, run_2, ... run_30 folder.

## IMPORTANT
Don't forget to save your results before you go outside of the folder, if you use rsync, 
otherwise you will lose all of your results.  