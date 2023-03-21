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

<h2 align="center">Replication Repository for  <br /> "Economic Impacts of the US Innovation and Competition Act" (March 2022)  <br /> by Matt Mazewski and Christian Flores</h2>
  <p align="center">
    Readme by Matt Mazewski (February 2023)
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

The files in this repository allow for replication of the figures in the March 2022 memo entitled ["Economic Impacts of the U.S. Innovation and Competition Act."](https://www.filesforprogress.org/memos/Economic-Impacts-of-USICA.pdf) 

In this memo, we made use of the Data for Progress Jobs Model to conduct a macroeconomic analysis of the United States Innovation and Competition Act (USICA), an ambitious piece of legislation designed to dramatically increase federal investments in scientific and technological research and development (R&D) that passed the Senate by a vote of 68-32 in June 2021. Portions of USICA later became law as part of the CHIPS and Science Act signed by President Biden in August 2022.

Key findings from our analysis were that the appropriations provisions of USICA would have contributed between $44 billion and $51 billion per year to U.S. GDP from 2022 through 2027, and would have created or preserved a total of between 2.6 million and 3.0 million jobs over the same period.

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

To replicate the results in the memo, run the program called **Run_USICA_Model.do**, which is located in the **Programs** folder. Be sure to change the working directory at the top of the code to reflect your own filepaths.
<br /> <br />
The comments in this program describe the model implementation in greater detail, but after running it the final results will be saved in the **Output** folder. In particular:

- **USICA_Total_Spending_by_Fiscal_Year.dta** contains total spending authorized by USICA for each year from 2022 to 2027, as reported in Table 1 on pg. 3 of the memo;
- **USICA_Model_Run_Final_Results_Low_Scenario.dta** contains estimated aggregate employment effects from the model run with "low" parameter values, which correspond to those reported in the top row of Table 2 and the bottom line of Figure 1 on pg. 4, as well as estimated GDP effects from the same, reported in the top row of Table 4 and bottom line of Figure 2 on pg. 6;
- **USICA_Model_Run_Final_Results_Baseline_Scenario.dta** contains estimated aggregate employment effects from the baseline model run, which correspond to those reported in the middle row of Table 2 and the middle line of Figure 1 on pg. 4, as well as estimated GDP effects from the same, reported in the middle row of Table 4 and middle line of Figure 2 on pg. 6;
- **USICA_Model_Run_Final_Results_High_Scenario.dta** contains estimated aggregate employment effects from the model run with "high" parameter values, which correspond to those reported in the bottom row of Table 2 and the top line of Figure 1 on pg. 4, as well as estimated GDP effects from the same, reported in the bottom row of Table 4 and top line of Figure 2 on pg. 6;
- **USICA_Model_Run_Final_Sector_Results_Baseline_Scenario.dta** contains estimates of aggregate employment effects by two-digit NAICS industry over the period 2022-2027 from the baseline model run, as reported in Table 3 on pg. 5; 
- **USICA_Model_Run_Final_State_Results_Baseline_Scenario.dta** contains estimates of aggregate employment effects by state over the period 2022-2027 from the baseline model run, as reported in Table 5 on pg. 8. 

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
