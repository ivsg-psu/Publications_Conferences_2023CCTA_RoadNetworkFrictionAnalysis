

<!--
The following template is based on:
Best-README-Template
Search for this, and you will find!
>
<!-- PROJECT LOGO -->
<br />
<p align="center">
  <!-- <a href="https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a> -->

  <h2 align="center"> Analysis of Friction Utilization Within a Roadway Network Using Simulated Vehicle Trajectories
  </h2>

<p align="center"><img src=".\Images\Friction_Analysis_Map_No_LC.jpg" alt="Friction Utilization Map" width="800" height="500">

  <p align="center">
    The purpose of this code is to create a friction utilization map of the State College road network in the manuscript "Analysis of Friction Utilization Within a Roadway Network Using Simulated Vehicle Trajectories".
    <br />
    <a href="https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/tree/main/Documents">View Demo</a>
    ·
    <a href="https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/issues">Report Bug</a>
    ·
    <a href="https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/issues">Request Feature</a>
  </p>
</p>



<!-- TABLE OF CONTENTS -->
<details open="open">
  <summary><h2 style="display: inline-block">Table of Contents</h2></summary>
  <ol>
    <li>
      <a href="#about-the-project">About the Project</a>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="structure">Repo Structure</a>
	    <ul>
	    <li><a href="#directories">Top-Level Directories</li>
	    </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
	    <ul>
	    <li><a href="#Generate-the-friction-utilization-data-for-the-State-College-road-network">Generate the friction utilization data for the State College road                    network</li>
	    </ul>
	    <ul>
	    <li><a href="#Generate-the-friction-utilization-map-of-the-State-College-road-network">Generate the friction utilization map of the State College road network</li>
	    </ul>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

In a road network, differences in road geometry, traffic patterns, and traffic laws require a range of typical maneuvers, each of which strongly affects the vehicle’s expected friction utilization. For example, very little tire force is required for driving straight on a low-speed road at a constant speed, performing no lane change maneuvers. Conversely, large tire forces may be required to navigate sharp highway curves, to stay in lane during sudden changes in lane offsets in a construction zone, or to stop abruptly from free-flow speed at a traffic light. Therefore, maps of this likely utilization are extremely valuable because they would reveal geolocations within a road network that require little relative friction utilization, and locations of large friction utilization. Such maps then may be useful to warn human drivers against lane changes on wet highway curves, to guide autonomous driving and/or driver assist algorithms toward geo-appropriate maneuver choices, or to modify as a function of weather the posted speed limits at road network locations whose normal maneuvering speed might violate friction limits. 

The goal of this paper is to predict the areas of large friction utilization within a traffic network by using recorded vehicle trajectories. These trajectories are used as reference paths within a simulation of chassis dynamics along with a steering algorithm to predict the friction utilization as a function of road location. The friction utilization values are then mapped to geolocations to identify zones where friction utilization is largest. Knowing these locations allows the planning of maneuvers by both drivers and driving algorithms such that friction margins are maintained. The results show that, within a typical traffic network, there are significant and very highly localized areas where large friction utilization is typical.


<!-- GETTING STARTED -->
## Getting Started

To get a local copy up and running follow these simple steps.

### Installation

1.  Make sure to run MATLAB 2020b or higher

2. Clone the repo
   ```sh
   git clone https://github.com/ivsg-psu/Publications_Conferences_2023CCTA_RoadNetworkFrictionAnalysis
   ```
3. Download the datafiles from <a href="https://pennstateoffice365.sharepoint.com/sites/IntelligentVehiclesandSystemsGroup-Active/Shared%20Documents/Forms/AllItems.aspx?ga=1&id=%2Fsites%2FIntelligentVehiclesandSystemsGroup%2DActive%2FShared%20Documents%2FIVSG%2FGitHubMirror%2FPublications%2FConferences%2F2023%2FPublications%5FConferences%5F2023CCTA%5FRoadNetworkFrictionAnalysis&viewid=aa025233%2D06cc%2D49ea%2Dbed2%2Db847e0f89798"><strong>psu-ivsg data cetner</strong></a> into the /Data folder. 

<!-- STRUCTURE OF THE REPO -->
### Directories
The following are the top level directories within the repository:
<ul>
	<li>/Documents folder: Paper manuscript and code description.</li>
	<li>/DB Lib folder: Database library with functions used by the code repository.</li>
	<li>/MinMaxMean folder: Min, max, and mean tracking function used by the code repository.</li>
	<li>/Path Lib folder: Path following library with functions used by the code repository.</li>
	<li>/UTM Lib folder: UTM library with functions used by the code repository.</li>
	<li>/VD Lib folder: Vehicle dynamics library with functions used by the code repository.</li>
	<li>/Data folder: Data files used by the code repository.</li>
	<li>/Images folder: Images generated by the code.</li>
</ul>


<!-- USAGE EXAMPLES -->
## Usage
<!-- Use this space to show useful examples of how a project can be used.
Additional screenshots, code examples and demos work well in this space. You may
also link to more resources. -->
### Generate the friction utilization data for the State College road network
** Please note: This main script cannot run without access and connection to the database hosted by Penn State University, which unfortunately, cannot be provided. However, if you would like to run this script with connection to your own database, you will need to change the database parameters. 
1. Download the datafiles from <a href="https://pennstateoffice365.sharepoint.com/sites/IntelligentVehiclesandSystemsGroup-Active/Shared%20Documents/Forms/AllItems.aspx?ga=1&id=%2Fsites%2FIntelligentVehiclesandSystemsGroup%2DActive%2FShared%20Documents%2FIVSG%2FGitHubMirror%2FPublications%2FConferences%2F2023%2FPublications%5FConferences%5F2023CCTA%5FRoadNetworkFrictionAnalysis&viewid=aa025233%2D06cc%2D49ea%2Dbed2%2Db847e0f89798"><strong>psu-ivsg data cetner</strong></a> into the /Data folder. 
2. Run the main script:
```sh
   script_estimateAccelForSmoothTrafficTrajSCE_RCL_3DoFPPC.m
   ```
### Generate the friction utilization map of the State College road network
1. Download the datafiles from <a href="https://pennstateoffice365.sharepoint.com/sites/IntelligentVehiclesandSystemsGroup-Active/Shared%20Documents/Forms/AllItems.aspx?ga=1&id=%2Fsites%2FIntelligentVehiclesandSystemsGroup%2DActive%2FShared%20Documents%2FIVSG%2FGitHubMirror%2FPublications%2FConferences%2F2023%2FPublications%5FConferences%5F2023CCTA%5FRoadNetworkFrictionAnalysis&viewid=aa025233%2D06cc%2D49ea%2Dbed2%2Db847e0f89798"><strong>psu-ivsg data cetner</strong></a> into the /Data folder. 

2. Run the main script:

   ```sh
   script_visualizeFrictionDemandForTraffic.m
   ```
You may change the various flag triggers to plot different data.
- Plot the minimum, maximum, or mean
- Plot the front left tire, the front right tire, the rear left tire, or the rear right tire


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` for more information.


## Major release versions
This code is still in development (alpha testing)


<!-- CONTACT -->
## Contact
Sean Brennan - sbrennan@psu.edu

Project Link: [https://github.com/ivsg-psu/Publications_Conferences_2023CCTA_RoadNetworkFrictionAnalysis](https://github.com/ivsg-psu/Publications_Conferences_2023CCTA_RoadNetworkFrictionAnalysis)



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation.svg?style=for-the-badge
[contributors-url]: https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation.svg?style=for-the-badge
[forks-url]: https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/network/members
[stars-shield]: https://img.shields.io/github/stars/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation.svg?style=for-the-badge
[stars-url]: https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/stargazers
[issues-shield]: https://img.shields.io/github/issues/ivsg-psu/reFeatureExtraction_Association_PointToPointAssociationpo.svg?style=for-the-badge
[issues-url]: https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/issues
[license-shield]: https://img.shields.io/github/license/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation.svg?style=for-the-badge
[license-url]: https://github.com/ivsg-psu/FeatureExtraction_Association_PointToPointAssociation/blob/master/LICENSE.txt








