# nanoindentation #
This repository is currently pre-release, meaning I do not recommend anyone but myself to use this code.


### What is this repository for? ###
The repository contains the code to calculate indentation moduli and hardness values of indentation tests. It assumes the material response is a combination of elastic, plastic and linearly viscoelastic mechanisms.

### How do I get set up? ###
* The repository is missing the function **readIBW.m**. This function reads the binary files output by an Asylum Research/Oxford Instruments Atomic Force Microscopy (AFM) machine. I do not own the rights to this file, so I cannot share it freely. There are alternative codes out there, e.g. 
    * https://se.mathworks.com/matlabcentral/fileexchange/42679-igor-pro-file-format-ibw-to-matlab-variable
    * https://cran.r-project.org/web/packages/IgorR/

    but I did not attempt to use them.


* The repository has been designed to be possible to run from both MATLAB and Octave. Although this is the intention, I do not guarantee that this will always work, as I develop on MATLAB.

If you have access to the file, you can clone or download this repository. The code here is the "functional" part of the program, but typically we use a script to specify links to the data and to plot the outputs.

### Where can I read more about the equations implemented?
The basics of nano-indentation testing is the theory of Hertzian contact. All developments share this fundamental base. Beyond a general understanding of Hertz contact theory, I recommend the following articles to understand this repository:

    Oliver, W. C., & Pharr, G. M. (1992). An improved technique for determining hardness and elastic modulus using load and displacement sensing indentation experiments. Journal of Materials Research, 7(6), 1564–1583. https://doi.org/10.1557/JMR.1992.1564
    
    Oliver, W. C., & Pharr, G. M. (2004). Measurement of hardness and elastic modulus by instrumented indentation: Advances in understanding and refinements to methodology. Journal of Materials Research, 19(1), 3–20. https://doi.org/10.1557/jmr.2004.19.1.3

    Feng, G., & Ngan, A. H. W. (2002). Effects of creep and thermal drift on modulus measurement using depth-sensing indentation. Journal of Materials Research, 17(3), 660–668. https://doi.org/10.1557/JMR.2002.0094

    Tang, B., & Ngan, A. H. W. (2003). Accurate measurement of tip - Sample contact size during nanoindentation of viscoelastic materials. Journal of Materials Research, 18(5), 1141–1148. https://doi.org/10.1557/JMR.2003.0156

    Cheng, Y. T., & Cheng, C. M. (2005). Relationships between initial unloading slope, contact depth, and mechanical properties for conical indentation in linear viscoelastic solids. Journal of Materials Research, 20(4), 1046–1053. https://doi.org/10.1557/JMR.2005.0141

    Cheng, Y. T., & Cheng, C. M. (2005). Relationships between initial unloading slope, contact depth, and mechanical properties for spherical indentation in linear viscoelastic solids. Materials Science and Engineering A, 409(1–2), 93–99. https://doi.org/10.1016/j.msea.2005.05.118

### Contribution guidelines ###
If you have a suggestion I propose that you contact me directly and I will try to accomodate you.

### Who do I talk to? ###

* August Brandberg augustbr at k t h . s e.

