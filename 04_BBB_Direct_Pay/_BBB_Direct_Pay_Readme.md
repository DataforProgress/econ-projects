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

<h2 align="center">Replication Repository for "Measuring the Economic Benefits of the <br /> Build Back Better Agenda's Direct Pay Provisions" (June 2022) <br /> by Matt Mazewski and Christian Flores</h2>
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

The files in this repository allow for replication of the figures in the June 2022 memo entitled ["Measuring the Economic Benefits
of the Build Back Better Agenda?s Direct Pay Provisions."](https://www.filesforprogress.org/memos/MEMO_DirectPay2.pdf) 

In recognition of the fact that administrative and bureaucratic barriers have often made it difficult for many individuals and firms to take full advantage of federal clean energy tax credits, the proposals comprising President Biden's Build Back Better (BBB) agenda not only included expansions and extensions of existing green incentives but also sought to increase their use by reviving a mechanism known as Direct Pay. Modeled on an earlier initiative under the 2009 American Recovery and Reinvestment Act (ARRA), Direct Pay would allow tax credits to be paid out as cash rather than simply as reductions
in incurred tax liability. (The Inflation Reduction Act enacted by Congress in August 2022, which contained many of the earlier elements of BBB, featured a more scaled-back version of Direct Pay with eligibility limited to nonprofits, rural electric cooperatives, and state, local, and tribal governments.)

In this memo, we employed the Data for Progress Jobs Model to provide estimates of the impact that a Direct Pay option would have on jobs and economic output relative to that which would otherwise result from the expansion of credits contemplated by the BBB agenda. Based on an analysis of the earlier round of Direct Pay grants, as well as assumptions about what projects face difficulty accessing green credits under the current system, we found that such an option would have created or preserved an additional 4.3 million job-years and contributed an additional $568 billion over the period 2022-2031 relative to a scenario involving enactment of the credits under consideration without a Direct Pay option.

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

To replicate the results in the memo, run the program called **Run_BBB_Direct_Pay_Model.do**, which is located in the **Programs** folder. Be sure to change the working directory at the top of the code to reflect your own filepaths.
<br /> <br />
The comments in this program describe the model implementation in greater detail, but after running it the final results will be saved in the **Output** folder. In particular:

- **BBB_Direct_Pay_Total_Spending_by_Credit.dta** contains total spending on Direct Pay-eligible credits in Build Back Better for the period 2022 to 2031, as reported in Table 1 on pg. 4 of the memo;
- **Section_1603_Grant_Shares.dta** gives the shares of total spending under Section 1603 of the American Recovery and Reinvestment Act (ARRA) of 2009, which established a federal Direct Pay option for the first time, flowing to projects costing more or less than \$50 million (which we take to be a cutoff below which it is not feasible for projects to use tax equity investors to monetize credits). These shares are reported in Figure 1 on pg. 6; 
- **BBB_Direct_Pay_Model_Run_Final_Results.dta** contains estimated aggregate employment effects with and without Direct Pay for the period 2022 to 2031, as reported in Figure 2 on pg. 7 and Table 2a on pg. 8; and estimated aggregate effects on GDP with and without Direct Pay for the same period, as reported in Figure 3/Table 3 on pg. 10;
- **BBB_Direct_Pay_Model_Run_Final_Results_by_Sector.dta** contains estimated aggregate employment effects by sector with and without Direct Pay for the period 2022 to 2031, as reported in Table 2b on pg. 9.

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
