# Water Quality Analysis and Prediction at Mtendeli Refugee Camp in Tanzania
Bachelor Thesis, April 2018, University of Toronto

This is the directory of my bachelor thesis, the final milestone for completing my bachelor's degree in Engineering Science, University of Toronto, 2018. 

Today, refugees at the Mtendeli camp, Tanzania, fetch water manually from a tap stand to their camps to use for the next day or two. However, it is at times extremely challenging to assess whether the water is still safe to consume due to varying climate conditions every day and many opportunities of contamination in an often-unsanitary refugee camp environment. Well-known first- or second-order decay models have failed in producing consistently accurate predictions. This project first conducts an in-depth data analysis and takes a machine learning approach to predict future water quality to address these key issues.

For complete and detailed results, please refer to `Report.pdf`. For a brief overview, refer to `Presentation.pdf`.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

The required environment for running the code and reproducing the results is a computer with a valid installation of MATLAB. More specifically, [MATLAB 2018a](https://www.mathworks.com/help/distcomp/release-notes-R2018a.html) is used.

## Project Structure

The `project/` directory has the following folder (and file) structure:

* `data/`. Directory containing original dataset provided by Médecins Sans Frontières.

* `matlab/`. Folder containing the actual code files for the project:
    * `CleanData.m` Cleans data
    * `Clustering.m` Performs hierarchical clustering
    * `CustomEnsembleMethod.m` Creates an ensemble model of a number of algorithms
    * `DimRed.m` Dimensionality reduction by principal component analysis 
    * `EDA.m` Exploratory data analysis
    * `FeatSelect.m` Feature selection by multiple approaches
    * `GBTrees.m` Gradient-boosted trees algorithm
    * `KNN.m` K-nearest neighbors algorithm
    * `LinearRegression.m` Linear regression algorithm
    * `Main.m` Main function which calls all other functions
    * `NN.m` Neural networks algorithm
    * `RandomForest.m` Random forest algorithm
    * `SVMR.m` Support vector regression algorithm

* `Presentation.pdf`
* `Report.pdf`

## How to execute the files.
	
Download all functions in the same directory. Save the data in separate directory named `data/`. Run `Main.m` to see results.

## Authors

* **Jangwon Park**

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
