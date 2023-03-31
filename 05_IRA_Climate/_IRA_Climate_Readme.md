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

<h2 align="center">Replication Repository for "Economic Impacts of the Inflation Reduction Act's <br /> Climate and Energy Provisions" (January 2023) <br /> by Adewale Maye and Matt Mazewski</h2>
  <p align="center">
    Readme by Matt Mazewski (March 2023)
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

The files in this repository allow for replication of the figures in the January 2023 memo entitled ["Economic Impacts of the Inflation Reduction Act's Climate and Energy Provisions."](https://www.filesforprogress.org/memos/IRA-Climate-Jobs-Memo.pdf) 

In this memo, we employed the Data for Progress Jobs Model to project the output and employment effects of these provisions of the IRA, which was signed into law by President Biden on August 16, 2022. In addition to the many other significant changes it makes to federal tax policy, healthcare, and more, this landmark legislation constitutes the biggest climate investment in U.S. history and aims to accelerate domestic clean energy production, catalyze technological innovation, and reduce greenhouse gas (GHG) emissions.

Assuming that future Congresses appropriate funds at the levels authorized by the law, our analysis found that the spending contained in the climate and energy provisions of the IRA, together with the private investment that it would incentivize and support, would be responsible for an average of around 1 million jobs created or preserved from 2023 to 2032, and would contribute approximately $1.7 trillion to U.S. GDP over the same period. We further found that nearly 50 percent of these jobs would be concentrated in the construction and manufacturing sectors, with environmental remediation, agriculture and forestry,
and scientific and technical services accounting for significant portions of the overall employment impacts as well.

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

To replicate the results in the memo, run the program called **Run_IRA_Climate_Model.do**, which is located in the **Programs** folder. Be sure to change the working directory at the top of the code to reflect your own filepaths.
<br /> <br />
The comments in this program describe the model implementation in greater detail, but after running it the final results will be saved in the **Output** folder. In particular:

- **IRA_Climate_Total_Spending_by_Fiscal_Year_and_Category.dta** contains total expenditures authorized by the climate and energy provisions of the IRA, as reported in Table 1a on pg. 4 and Figure 1a on pg. 5 of the memo and Table 1b/Figure 1b on pg. 6;

- **IRA_Climate_Model_Run_Final_Results_Employment.dta** contains estimates of the average number of direct, indirect, induced, and total jobs created or preserved nationally over the period 2023 to 2032, as reported in Table 2 on pg. 7;

- **IRA_Climate_Model_Run_Final_Results_GDP.dta** contains estimates of the aggregate effects on U.S. GDP over the period 2023 to 2032, as reported in Table 3/Figure 2 on pg. 8;

- **IRA_Climate_Model_Run_Final_Results_by_Sector.dta** contains estimates of the average number of jobs created or preserved by sector over the period 2023 to 2032, as reported in Table 4 on pg. 9 (top five sectors) and Appendix E on pg. 17 (all twenty sectors);

- **IRA_Climate_Model_Run_Final_Results_by_State.dta** contains estimates of the average number of direct, indirect, induced, and total jobs created or preserved by state over the period 2023 to 2032, as reported in Table 5 on pg. 10 (top ten states) and Appendix D on pg. 16 (all 50 states plus DC). 

- **IRA_Climate_Model_Run_Final_Results_Averages_by_Category.dta** contains estimates of the average number of jobs created or preserved by category over the period 2023 to 2032, as reported in Table 6 on pg. 10.

- **IRA_Climate_Total_Spending_by_Category_and_Section.dta** contains a complete list of climate and energy expenditures in the Inflation Reduction Act by bill section, as reported in Appendix F on pg. 18. Note that the amounts in this table are taken from Congressional Budget Office (2022), ["Estimated Budgetary Effects of H.R. 5376, the Inflation Reduction Act of 2022,"](https://www.cbo.gov/publication/58366) and refer to what we call "public spending," i.e. federal expenditures excluding any partner matches or private spending that might be incentivized by public programs. This corresponds to what the CBO terms "estimated budgetary impacts" or "estimated
outlays," and often but does not always coincide with the amounts authorized by the law.

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
