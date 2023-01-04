<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->

<h2 align="center">Introduction to the Data for Progress Jobs Model</h2>
  <p align="center">
    Matt Mazewski
    <br />
    January 2023
    <br />
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About</a>
    </li>
    <li>
      <a href="#overview-of-repository">Overview of Repository</a>
      <ul>
        <li><a href="#directory-structure">Directory Structure</a></li>
        <li><a href="#replicating-results">Replicating Results</a></li>
      </ul>
    </li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT -->
## About

The files in this repository allow for replication of the figures in the February 2022 memo entitled ["Introduction to the Data for Progress Jobs Model."](https://www.filesforprogress.org/memos/Introduction-to-the-Data-for-Progress-Jobs-Model.pdf) The purpose of the model is to allow us to make informed projections of the likely effects of different pieces of legislation on employment and GDP by relying on a technique known as *input-output (I-O) analysis*. 

As Yogi Berra once said, "it's tough to make predictions, especially about the future," so we validated the performance of our model by using it to "backcast" job creation and GDP effects of the 2009 American Reinvestment and Recovery Act (ARRA) ("the 2009 stimulus") and then comparing our results to other estimates of the law's impacts from government and academic sources. We concluded in the memo that the DFP Jobs Model is capable of generating results that are in line with these independent estimates, which should help to give confidence in our findings when applying it to analyze other legislation.


<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- Overview of Repository -->
## Overview of Repository

The repository contains the following four folders:

### Directory Structure

1. **Data** - raw inputs needed to run model code;
2. **Output** - files containing final results shown in memo;
3. **Programs** - Stata code needed to compute model results; 
4. **Work** - intermediate results saved in the course of running the model code;


### Replicating Results

To replicate the results in the memo, run the program called **Run_ARRA_Model.do**, which is located in the **Programs** folder. Be sure to change the working directory at the top of the code to reflect your own filepaths.
<br /> <br />
The comments in this program describe the model implementation in greater detail, but after running it the final results will be saved in the **Output** folder. In particular:

- **ARRA_Spending_by_Year.dta** contains CBO forecasts of ARRA spending by year reported in the table and figure on pg. 3 of the memo;
- **ARRA_Model_Run_Final_Results_Baseline_Scenario.dta** contains results in the first table on pg. 4, which correspond to the middle lines in the figures on pg. 5;
- **ARRA_Model_Run_Final_Results_Alt_Scenario_1.dta** contains results in the second table on pg. 4 labeled "Alternative Scenario 1: Low Parameter Values," which correspond to the bottom lines in the figures on pg. 5;
- **ARRA_Model_Run_Final_Results_Alt_Scenario_2.dta** contains results in the third table on pg. 4 labeled "Alternative Scenario 2: High Parameter Values," which correspond to the top lines in the figures on pg. 5.


<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- CONTACT -->
## Contact

Matt Mazewski 
<br />
[@mattmazewski](https://twitter.com/twitter_handle)
<br />
matt@dataforprogress.org

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/github_username/repo_name.svg?style=for-the-badge
[contributors-url]: https://github.com/github_username/repo_name/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/github_username/repo_name.svg?style=for-the-badge
[forks-url]: https://github.com/github_username/repo_name/network/members
[stars-shield]: https://img.shields.io/github/stars/github_username/repo_name.svg?style=for-the-badge
[stars-url]: https://github.com/github_username/repo_name/stargazers
[issues-shield]: https://img.shields.io/github/issues/github_username/repo_name.svg?style=for-the-badge
[issues-url]: https://github.com/github_username/repo_name/issues
[license-shield]: https://img.shields.io/github/license/github_username/repo_name.svg?style=for-the-badge
[license-url]: https://github.com/github_username/repo_name/blob/master/LICENSE.txt
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://linkedin.com/in/linkedin_username
[product-screenshot]: images/screenshot.png
[Next.js]: https://img.shields.io/badge/next.js-000000?style=for-the-badge&logo=nextdotjs&logoColor=white
[Next-url]: https://nextjs.org/
[React.js]: https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB
[React-url]: https://reactjs.org/
[Vue.js]: https://img.shields.io/badge/Vue.js-35495E?style=for-the-badge&logo=vuedotjs&logoColor=4FC08D
[Vue-url]: https://vuejs.org/
[Angular.io]: https://img.shields.io/badge/Angular-DD0031?style=for-the-badge&logo=angular&logoColor=white
[Angular-url]: https://angular.io/
[Svelte.dev]: https://img.shields.io/badge/Svelte-4A4A55?style=for-the-badge&logo=svelte&logoColor=FF3E00
[Svelte-url]: https://svelte.dev/
[Laravel.com]: https://img.shields.io/badge/Laravel-FF2D20?style=for-the-badge&logo=laravel&logoColor=white
[Laravel-url]: https://laravel.com
[Bootstrap.com]: https://img.shields.io/badge/Bootstrap-563D7C?style=for-the-badge&logo=bootstrap&logoColor=white
[Bootstrap-url]: https://getbootstrap.com
[JQuery.com]: https://img.shields.io/badge/jQuery-0769AD?style=for-the-badge&logo=jquery&logoColor=white
[JQuery-url]: https://jquery.com 
