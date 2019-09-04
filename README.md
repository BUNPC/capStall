# capStall
# Description:
We use this GUI to identify capillary segments that exhibit a stalling event. We look at all images in a time series to identify all image frames in which the capillary segment stalled. Once we have done this for all stalling capillaries, we then end up with a stall-o-gram from which we are able to calculate several interesting statistics including: point prevalence, incidence, cumulative stall duration, etc.

# Input: 
The input for this function comes from capStallGUI_saveMIPtimeSeries.m which generates a folder which contains the time series MIP images labelled sequentially (000001.mat, 000002.mat, etc… but not like 1.mat, 2.mat, 3.mat etc..) and an average 3D volume for the same MIP range labelled as avgVolume.mat. The folder name should have information about the MIP range, which is produced by capStallGUI_saveMIPtimeSeries.m by default. Example: 

# Output: 
OutputFileName.mat contains 5 variables. The user defines the output file name.

The 5 variables are:

*Cap* [Nx2] - contains 2D coordinates of the capillary stall points in the MIP coordinate system

*Pts* [Nx3] - contains 3D coordinates of the capillary stall points in the 3D average volume

Seg [Nx1]- is a structure data type. 
*Seg.pos* [MX3]- contains positions of the capillary segment. Note that the number of node points M generally differs for each capillary segment.
*Seg.mask* [Px1] - contains a list of indices into the volume image indicating the voxels corresponding to the masked capillary segment.
*Int_ts* [N*T] - contains the intensity time series of each segment averaged over the list of Seg.mask voxels for the given segment
*StallingMatrix* [N*T] - is binary matrix with stalls indicated as 1 and non-stalls as 0. This is the famous stall-o-gram.

N - number of stalling capillary segments

T - number of images in the time series 


# Instructions to run CapStall GUI:
1. Select Load data in menu tool (Menu > Load Data)
1. A window prompt opens. Select the folder which has the MIP time series data
1. If needed, load previous results (Menu > Load results) or else go to next step 
1. Select stalling capillary segments on the MIP time series data (left axis) and average volume (right axis). It is advised to select a point near the center of the capillary segment. Don’t worry about selecting all stalling time points for each capillary at this moment. Only make sure to select all capillaries that exhibit a stalling event.
1. After selecting all of the stalling capillaries, save the results (Menu > Save results). Note that you are advised to regularly save your work as you progress. You don’t need to wait until everything is selected before saving.
1. Click the “segment analysis” button. This will start a process that automatically tracks each identified capillary segment a short distance in each direction from your selected “center” point. This will facilitate the subsequent time series analysis.
1. After some processing a matlab figure pops up with the tracked segments identified. Make sure to save this image for future reference. This is a matlab figure and so you use the standard matlab menu items to save the fig-file and/or export it to some other format.
1. For each stalling capillary, go through the time series MIP data and select the time points for when a stall occurs. Use the MIP images and the corresponding segment time series intensity plot to help you make these decisions. The mouse wheel helps you scroll through the time series MIP data and the spacebar helps you select/deselect a stall event. In general, if there is a stalling event, then the intensity should go down on the intensity plot. However, due to noise and motion artifacts, you may not always see the intensity going down even if you observe on the MIP images that a stalling event occurred.
1. Save results as OutputFileName.mat (Menu > Save results)
