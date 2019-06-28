# Dalmatian
Spot detection algorithm

USAGE:

1. In MATLAB, add the folder with the scripts to the path.
2. Open `runme.m` in the editor.
3. Set the parameters in `runme.m` to the default values:

```matlab
%Predefined values for sload

FNAMEFMT  = '*C0*.tif';   %To read the first channel of the dataset (regular expression).

%Predefined values for sstat

NTR       = 1000;         %Number of bootstrap trials
R         = 7;            %Radius of the region for the bootstrap
THRESHOLD = 0;            %Intensity threshold (absolute value): no threshold
LOWPASS   = 2;            %Low-pass filter standard deviation (in pixels) to reduce pixel noise
HIPASS    = 100;          %Hi-pass filter standard deviation (in pixels): substantially larger than the cell
MINREG    = 100;          %Minimal region size (in voxels) to calculate the statistics

%Predefined values for sselect

CONFLVL   = 0.1;          %P-value for the putative cell to match the following criteria
S1MIN     = 0;            %Standard deviations of the data (in pixels), fitted with Gaussian distribution:
S1MAX     = Inf;          %no limits
S2MIN     = 0;
S2MAX     = Inf;
S3MIN     = 0;
S3MAX     = Inf;
IMMIN     = 0;            %Signal intensity: no limits
IMMAX     = Inf;

%Task splitting parameters

SZ        = 500;          %Splitting the task into squares of the given size (in pixels) to fit the RAM.
OVERLAP   = 40;           %Overlap of the squares (in pixels) the task is divided into
INTERACT  = 1;            %1 - interact, 0 - no interaction
```
4. Switch to the folder, containing your data in TIFF format.
5. Adjust the Gaussian filtering parameters to remove noise and background.

The Gaussian low-pass filter standard deviation `LOWPASS` had to be both larger than the typical noise artifact radius and smaller than the typical cell radius (the largest one not to merge the overlapping cells). The best compromise value for the standard deviation of the low-pass filter was typically between 0.5 and several pixels.

The standard deviation of the Gaussian hi-pass filter `HIPASS` had to be both larger than the typical cell radius and smaller than the typical background feature radius (the smallest one not to wash out the cells). The best compromise value for the standard deviation of the hi-pass filter typically exceeded putative cell radius by the order of 1.5-2.

```matlab
LOWPASS   = 2;            %Low-pass filter standard deviation (in pixels): between 0.5 and several
HIPASS    = 6;            %Hi-pass filter standard deviation (in pixels): 1.5-2 cell sizes
```

Run `runme.m` using the following command:

```matlab
runme('load', 'noref');   %load the images from current directory; do not adjust the brigtness
```

Repeat the procedure of tuning `HIGHPASS` and `LOWPASS` paremeters, until in the `Watersheded image` figure each region would contain no more than one cell.

6. Adjust the intensity threshold.

In the `Preprocessed image` figure, use MATLAB figure `Data cursor` tool to measure the intensity of the remaining background.

To suppress the remaining background, we need to set to zero all the voxels with the intensities below the given threshold, typically 5-10% of the maximal intensity (in absolute values). Select the threshold not to exceed the cell signal intensity.

```matlab
THRESHOLD = 200;          %Intensity threshold (absolute value): 5-10% of the maximal value
```

Run `runme.m`. Repeat the procedure of tuning `THRESHOLD` paremeter, until in the `Preprocessed image` figure most of the background is removed.

7. Coarse tune the cell vs non-cell criteria.

In the `Histograms` window, select `S1MIN`, `S1MAX`, `S2MIN`, `S2MAX`, `S3MIN`, `S3MAX`, `IMMIN`, `IMMAX` parameters so that they will wrap the peak part (approximately, 4/5 of the area under the curve), but not the tail part of the corresponding histogram.

```matlab
S1MIN     = 4;            %Standard deviations of the data (in pixels), fitted with Gaussian distribution:
S1MAX     = 8;            %wrap the peak part, but not the noise part of the corresponding histogram
S2MIN     = 4;
S2MAX     = 8;
S3MIN     = 4;
S3MAX     = 8;
IMMIN     = 200;          %Signal intensity:
IMMAX     = Inf;          %wrap the peak part, but not the tail part of the corresponding histogram
```

8. Fine tune the cell vs non-cell criteria.

Run `runme.m`. In the `Detected spots image`, use the cross to click on the cells, both detected and not, to reveal the parameters for the individual cells. Tune the `S1MIN`, `S1MAX`, `S2MIN`, `S2MAX`, `S3MIN`, `S3MAX`, `IMMIN`, `IMMAX` parameters so that most of the cells would fit in these ranges, and the other objects would not fit.
Repeat the procedure of tuning these parameters until most of the cells are detected. If the detection remains poor, increase the p-value threshold `CONFLVL` and fine tune these parameters again.

```matlab
CONFLVL   = 0.3;          %P-value for the putative cell to match the detection criteria: increased
```

9. Save the results.

You can use your fine-tuned parameters for the samples with similar preparation.

Turn off the interaction mode using the `INTERACT` parameter and run `runme.m`:

```matlab
INTERACT  = 0;            %1 - interact, 0 - no interaction
```

To run the algorithm in batch mode, go to the `../` folder, containing folders with your samples, and run `sbatch.m` with the following parameters:

```matlab
sbatch(‘noref’, ‘*C0*’);  %do not adjust the brigtness; use the first channel
```
Alternatively, you may want to use histogram equalization to equalize 3D image data intensities in the dataset. Voxel intensities in every 3D image stack will be changed so that the histograms of every 3D image stack match the histogram of the first one, used to tune the parameters (recommended for noisy data).

```matlab
sbatch(‘YOUR_1ST_SAMPLE_FOLDER_NAME’, ‘*C0*’); %do not adjust the brigtness; use the first channel
```
The results would be saved both in MATLAB figure and data file formats. In the data file format, three colums would stand for the detected spot coordinates.

10. Colocalize the detected cells in different channels (optional)

In the folder with the output data files, run `scolocolize` with the maximal distance and the numbers of the channels to be colocoized as parametes: 

```matlab
scolocolize(7, 'C0', 'C1'); %detected spots no more than 7 px apart in the first and the second channels
```
Similarly, the results would be saved both in MATLAB figure and data file formats. In the data file format, three colums would stand for the detected spot coordinates.

11. Subselect the cells within a ROI (optional)

In the folder with the output Matlab figures containing the detected cells, run `sselectreg` with the filename of interest as a parameter:

```matlab
sselectreg('your_file_name.fig'); %allows to subselect cells in 'your_file_name.fig'
```
To define polygonal region of interest (ROI), use mouse clicks to define vertices. Once finished, click outside the plot area.

REMOVING AUTOFLUORESCENCE (optional)

Before running the spot detection, in the folder, containing folders with your samples, run `sclean.m` with the channel numbers as the parameters.

```matlab
sclean(0, 1);             %remove the mutual autofluorescence in the first and the second channels
```

The results would be saved as separate folders with TIFF files. The other channels will be also copied.
