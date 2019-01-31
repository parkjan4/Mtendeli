# Water Quality Analysis and Prediction at Mtendeli Refugee Camp in Tanzania
Bachelor Thesis, April 2018, University of Toronto

This is the directory of my project as the final milestone for completing my bachelor's degree in Engineering Science, University of Toronto, 2018. 

Today, refugees at the Mtendeli camp, Tanzania, fetch water manually from a tap stand to their camps to use for the next day or two. However, it is at times extremely challenging to assess whether the water is still safe to consume due to varying climate conditions every day and many opportunities of contamination in an often-unsanitary refugee camp environment. Well-known first- or second-order decay models have failed in producing consistently accurate predictions. This project first conducts an in-depth data analysis and takes a machine learning approach to predict future water quality to address these key issues.

For complete and detailed results, please refer to `Report.pdf`. For a brief overview, refer to `Presentation.pdf`.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

The required environment for running the code and reproducing the results is a computer with a valid installation of MATLAB. More specifically, [MATLAB 2018a](https://www.mathworks.com/help/distcomp/release-notes-R2018a.html) is used.

## Project Structure

The project has the following folder (and file) structure:

* `data/`. Directory containing original dataset from LINQS. [online] Linqs.soe.ucsc.edu. Available at: https://linqs.soe.ucsc.edu/node/236 [Accessed 11 Jan. 2019].

* `matlab/`. Folder containing the actual code files for the project:
    * `gephi/` Folder containing gephi files for visualization and exploration of the network.
    * `images/` Folder containing different images that are generated when running the different notebooks.
    * `fragmentation measures.py` Contains functions to compute fragmentation measures on the provided network.
    * `optimization_algorithms.py` Contains both optimization algorithms for fragmentation and information flow as well as the necessary functions to compute the respectives objective values. 
    * `data_exploration_functions.py` Contains several functions used for the import and parse of the data, creation of the network structure or identification of largest component among others.
    * `fragmentation.ipynb` Notebook containing initial data exploration as well as optimization task and results on the fragmentation problem. The provided notebook is already executed and shows the desired results.
    * `information_flow.ipynb` Notebook containing the data exploration and optimization task and results on the information diffusion problem. The provided notebook is already executed and shows the desired results. A new execution can take around 15 to 20 minutes. 
    * `adjacency.npy` Numpy file containing the structure of the adjacency matrix of the original network. Can be used to avoid creating it from scratch if a new execution of any of the two notebooks wants to be done. 

* `Report.pdf`
* `requirements.txt`


## How to execute the files.
	
Only fragmentation and information flow Notebooks are intended to be executed. All other files do not provide any directly readable result. The project has been developed so that fragmentation notebook is read first as it contains an initial exploration of the data. Nevertheless, information_flow notebook can be read and understood without need of previous consultation to the fragmentation notebook, taking into account the reader is aware of the purpose of the project.

## Authors

* **Abrate, Marco Pietro** - 
* **Bolón Brun, Natalie** - 
* **Kakavandy, Shahow** - 
* **Park, Jangwon** - 

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details
