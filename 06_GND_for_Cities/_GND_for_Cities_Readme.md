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

<h2 align="center">Replication Repository for "Economic Impacts of the Green New Deal for Cities Act" (April 2023) <br /> by Adewale Maye and Matt Mazewski</h2>
  <p align="center">
    Readme by Matt Mazewski (May 2023)
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

The files in this repository allow for replication of the figures in the April 2023 memo entitled ["Economic Impacts of the Green New Deal for Cities Act."](https://www.dataforprogress.org/memos/economic-impacts-of-the-green-new-deal-for-cities-act) 

In this memo, we employed the Data for Progress Jobs Model to provide projections of the impact that an updated Green New Deal for Cities Act would have on economic output and employment across the U.S. First introduced in the House in April 2021 by Rep. Cori Bush (D-MO-01) and several dozen cosponsors, this expansive legislation is designed to enable communities from across the nation to combat the effects of climate change while also providing economic security for American workers and their families. The bill would prioritize the needs of historically marginalized groups and communities that depend heavily on the fossil fuel economy, both of which stand to be especially severely impacted by climate change and to experience significant economic dislocations from decarbonization.

The Green New Deal for Cities Act authorizes $1 trillion in appropriations to a dedicated fund over a four-year period, with grants for clean energy projects, climate mitigation, and other allowable purposes allocated to state, territorial, Tribal, county, and local governments according to a formula used in the American Rescue Plan Act of 2021 to distribute grants from the Coronavirus State and Local Fiscal Recovery Funds.

Assuming that a new iteration of the bill were introduced that featured the same funding authorizations and allocation mechanisms as the original House version from 2021 (H.R. 2644), and that its spending provisions were to take effect in Fiscal Year 2024, we estimate that a Green New Deal for Cities Act would be responsible for an average of around 1.9 million jobs created or preserved over the period 2024 to 2027, and would contribute around $1.2 trillion to U.S. GDP over the same. 

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

To replicate the results in the memo, run the program called **Run_GND_for_Cities_Model.do**, which is located in the **Programs** folder. Be sure to change the working directory at the top of the code to reflect your own filepaths.
<br /> <br />
The comments in this program describe the model implementation in greater detail, but after running it the final results will be saved in the **Output** folder. In particular:

- **GND_for_Cities_Model_Final_Results_Employment.dta** contains estimates of the average number of direct, indirect, induced, and total jobs created or preserved nationally over the period 2024 to 2027, as reported in Table 3 on pg. 7;

- **GND_for_Cities_Model_Final_Results_GDP.dta** contains estimates of the aggregate effects on U.S. GDP over the period 2024 to 2027, as reported in in Table 4/Figure 2 on pg. 8;

- **GND_for_Cities_Model_Final_Results_by_Sector.dta** contains estimates of the average number of jobs created or preserved by sector over the period 2024 to 2027, as reported in Table 5 on pg. 9 (top ten sectors) and Appendix D on pg. 17 (all twenty sectors) contains results in Appendix D;

- **GND_for_Cities_Model_Final_Results_by_State.dta** contains estimates of the average number of direct, indirect, induced, and total jobs created or preserved by state over the period 2024 to 2027, as reported in Table 6 on pg. 10 (top ten states) and Appendix E (all 50 states plus DC);

- **GND_for_Cities_Model_Final_Results_by_MSA.dta** contains estimates of the average number of direct, indirect, induced, and total jobs created or preserved by metropolitan area over the period 2024 to 2027, as reported in Table 7 on pg. 11 (top 40 metro areas) and Appendix F (top 250 metro areas).

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
