--------------------------------------------------------------------------------
--                    RightShifter53_by_max_163_F100_uid4
-- VHDL generated for Kintex7 @ 100MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2008-2011), Florent de Dinechin (2008-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 1 cycles
-- Clock period (ns): 10
-- Target frequency (MHz): 100
-- Input signals: X S
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity RightShifter53_by_max_163_F100_uid4 is
    port (clk : in std_logic;
          X : in  std_logic_vector(52 downto 0);
          S : in  std_logic_vector(7 downto 0);
          R : out  std_logic_vector(215 downto 0)   );
end entity;

architecture arch of RightShifter53_by_max_163_F100_uid4 is
signal ps, ps_d1 :  std_logic_vector(7 downto 0);
signal level0 :  std_logic_vector(52 downto 0);
signal level1 :  std_logic_vector(53 downto 0);
signal level2 :  std_logic_vector(55 downto 0);
signal level3 :  std_logic_vector(59 downto 0);
signal level4 :  std_logic_vector(67 downto 0);
signal level5 :  std_logic_vector(83 downto 0);
signal level6 :  std_logic_vector(115 downto 0);
signal level7, level7_d1 :  std_logic_vector(179 downto 0);
signal level8 :  std_logic_vector(307 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            ps_d1 <=  ps;
            level7_d1 <=  level7;
         end if;
      end process;
   ps<= S;
   level0<= X;
   level1 <=  (0 downto 0 => '0') & level0 when ps(0) = '1' else    level0 & (0 downto 0 => '0');
   level2 <=  (1 downto 0 => '0') & level1 when ps(1) = '1' else    level1 & (1 downto 0 => '0');
   level3 <=  (3 downto 0 => '0') & level2 when ps(2) = '1' else    level2 & (3 downto 0 => '0');
   level4 <=  (7 downto 0 => '0') & level3 when ps(3) = '1' else    level3 & (7 downto 0 => '0');
   level5 <=  (15 downto 0 => '0') & level4 when ps(4) = '1' else    level4 & (15 downto 0 => '0');
   level6 <=  (31 downto 0 => '0') & level5 when ps(5) = '1' else    level5 & (31 downto 0 => '0');
   level7 <=  (63 downto 0 => '0') & level6 when ps(6) = '1' else    level6 & (63 downto 0 => '0');
   level8 <=  (127 downto 0 => '0') & level7_d1 when ps_d1(7) = '1' else    level7_d1 & (127 downto 0 => '0');
   R <= level8(307 downto 92);
end architecture;

--------------------------------------------------------------------------------
--                             LZC_110_F100_uid6
-- VHDL generated for Kintex7 @ 100MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, Bogdan Pasca (2007)
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles
-- Clock period (ns): 10
-- Target frequency (MHz): 100
-- Input signals: I
-- Output signals: O

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity LZC_110_F100_uid6 is
    port (clk : in std_logic;
          I : in  std_logic_vector(109 downto 0);
          O : out  std_logic_vector(6 downto 0)   );
end entity;

architecture arch of LZC_110_F100_uid6 is
signal level7 :  std_logic_vector(126 downto 0);
signal digit6 :  std_logic;
signal level6 :  std_logic_vector(62 downto 0);
signal digit5 :  std_logic;
signal level5 :  std_logic_vector(30 downto 0);
signal digit4 :  std_logic;
signal level4 :  std_logic_vector(14 downto 0);
signal digit3 :  std_logic;
signal level3 :  std_logic_vector(6 downto 0);
signal digit2 :  std_logic;
signal level2 :  std_logic_vector(2 downto 0);
signal lowBits :  std_logic_vector(1 downto 0);
signal outHighBits :  std_logic_vector(4 downto 0);
begin
   -- pad input to the next power of two minus 1
   level7 <= I & "11111111111111111";
   -- Main iteration for large inputs
   digit6<= '1' when level7(126 downto 63) = "0000000000000000000000000000000000000000000000000000000000000000" else '0';
   level6<= level7(62 downto 0) when digit6='1' else level7(126 downto 64);
   digit5<= '1' when level6(62 downto 31) = "00000000000000000000000000000000" else '0';
   level5<= level6(30 downto 0) when digit5='1' else level6(62 downto 32);
   digit4<= '1' when level5(30 downto 15) = "0000000000000000" else '0';
   level4<= level5(14 downto 0) when digit4='1' else level5(30 downto 16);
   digit3<= '1' when level4(14 downto 7) = "00000000" else '0';
   level3<= level4(6 downto 0) when digit3='1' else level4(14 downto 8);
   digit2<= '1' when level3(6 downto 3) = "0000" else '0';
   level2<= level3(2 downto 0) when digit2='1' else level3(6 downto 4);
   -- Finish counting with one LUT
   with level2  select  lowBits <= 
      "11" when "000",
      "10" when "001",
      "01" when "010",
      "01" when "011",
      "00" when others;
   outHighBits <= digit6 & digit5 & digit4 & digit3 & digit2 & "";
   O <= outHighBits & lowBits ;
end architecture;

--------------------------------------------------------------------------------
--                    LeftShifter163_by_max_162_F100_uid8
-- VHDL generated for Kintex7 @ 100MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2008-2011), Florent de Dinechin (2008-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 2 cycles
-- Clock period (ns): 10
-- Target frequency (MHz): 100
-- Input signals: X S
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity LeftShifter163_by_max_162_F100_uid8 is
    port (clk : in std_logic;
          X : in  std_logic_vector(162 downto 0);
          S : in  std_logic_vector(7 downto 0);
          R : out  std_logic_vector(324 downto 0)   );
end entity;

architecture arch of LeftShifter163_by_max_162_F100_uid8 is
signal ps, ps_d1, ps_d2 :  std_logic_vector(7 downto 0);
signal level0 :  std_logic_vector(162 downto 0);
signal level1, level1_d1 :  std_logic_vector(163 downto 0);
signal level2 :  std_logic_vector(165 downto 0);
signal level3 :  std_logic_vector(169 downto 0);
signal level4 :  std_logic_vector(177 downto 0);
signal level5 :  std_logic_vector(193 downto 0);
signal level6 :  std_logic_vector(225 downto 0);
signal level7, level7_d1 :  std_logic_vector(289 downto 0);
signal level8 :  std_logic_vector(417 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            ps_d1 <=  ps;
            ps_d2 <=  ps_d1;
            level1_d1 <=  level1;
            level7_d1 <=  level7;
         end if;
      end process;
   ps<= S;
   level0<= X;
   level1<= level0 & (0 downto 0 => '0') when ps(0)= '1' else     (0 downto 0 => '0') & level0;
   level2<= level1_d1 & (1 downto 0 => '0') when ps_d1(1)= '1' else     (1 downto 0 => '0') & level1_d1;
   level3<= level2 & (3 downto 0 => '0') when ps_d1(2)= '1' else     (3 downto 0 => '0') & level2;
   level4<= level3 & (7 downto 0 => '0') when ps_d1(3)= '1' else     (7 downto 0 => '0') & level3;
   level5<= level4 & (15 downto 0 => '0') when ps_d1(4)= '1' else     (15 downto 0 => '0') & level4;
   level6<= level5 & (31 downto 0 => '0') when ps_d1(5)= '1' else     (31 downto 0 => '0') & level5;
   level7<= level6 & (63 downto 0 => '0') when ps_d1(6)= '1' else     (63 downto 0 => '0') & level6;
   level8<= level7_d1 & (127 downto 0 => '0') when ps_d2(7)= '1' else     (127 downto 0 => '0') & level7_d1;
   R <= level8(324 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                                   FMA_D
--                         (IEEEFMA_11_52_F100_uid2)
-- Inputs: this FMA computes A*B+C
-- VHDL generated for Kintex7 @ 100MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin (2009-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 3 cycles
-- Clock period (ns): 10
-- Target frequency (MHz): 100
-- Input signals: A B C negateAB negateC RndMode
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FMA_D is
    port (clk : in std_logic;
          A : in  std_logic_vector(63 downto 0);
          B : in  std_logic_vector(63 downto 0);
          C : in  std_logic_vector(63 downto 0);
          negateAB : in  std_logic;
          negateC : in  std_logic;
          RndMode : in  std_logic_vector(1 downto 0);
          R : out  std_logic_vector(63 downto 0)   );
end entity;

architecture arch of FMA_D is
   component RightShifter53_by_max_163_F100_uid4 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(52 downto 0);
             S : in  std_logic_vector(7 downto 0);
             R : out  std_logic_vector(215 downto 0)   );
   end component;

   component LZC_110_F100_uid6 is
      port ( clk : in std_logic;
             I : in  std_logic_vector(109 downto 0);
             O : out  std_logic_vector(6 downto 0)   );
   end component;

   component LeftShifter163_by_max_162_F100_uid8 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(162 downto 0);
             S : in  std_logic_vector(7 downto 0);
             R : out  std_logic_vector(324 downto 0)   );
   end component;

signal Asgn, Asgn_d1 :  std_logic;
signal AexpField :  std_logic_vector(10 downto 0);
signal AsigField :  std_logic_vector(51 downto 0);
signal AisNormal :  std_logic;
signal AisInfOrNaN :  std_logic;
signal AhasNonNullSig :  std_logic;
signal AisZero, AisZero_d1 :  std_logic;
signal AisInf :  std_logic;
signal AisNaN :  std_logic;
signal Bsgn, Bsgn_d1 :  std_logic;
signal BexpField :  std_logic_vector(10 downto 0);
signal BsigField :  std_logic_vector(51 downto 0);
signal BisNormal :  std_logic;
signal BisInfOrNaN :  std_logic;
signal BhasNonNullSig :  std_logic;
signal BisZero, BisZero_d1 :  std_logic;
signal BisInf :  std_logic;
signal BisNaN :  std_logic;
signal Aexp :  std_logic_vector(10 downto 0);
signal Bexp :  std_logic_vector(10 downto 0);
signal Asig :  std_logic_vector(52 downto 0);
signal Bsig :  std_logic_vector(52 downto 0);
signal AexpPlusBexp, AexpPlusBexp_d1 :  std_logic_vector(11 downto 0);
signal Csgn, Csgn_d1 :  std_logic;
signal CexpField :  std_logic_vector(10 downto 0);
signal CsigField :  std_logic_vector(51 downto 0);
signal CisNormal, CisNormal_d1 :  std_logic;
signal CisInfOrNaN :  std_logic;
signal ChasNonNullSig :  std_logic;
signal CisZero, CisZero_d1 :  std_logic;
signal CisInf :  std_logic;
signal CisNaN :  std_logic;
signal RisNaN, RisNaN_d1, RisNaN_d2, RisNaN_d3 :  std_logic;
signal tentativeRisInf, tentativeRisInf_d1, tentativeRisInf_d2, tentativeRisInf_d3 :  std_logic;
signal Cexp, Cexp_d1 :  std_logic_vector(10 downto 0);
signal effectiveSub, effectiveSub_d1 :  std_logic;
signal Csig :  std_logic_vector(52 downto 0);
signal expDiffPrepare :  std_logic_vector(12 downto 0);
signal expDiff :  std_logic_vector(12 downto 0);
signal tmpExpComp1 :  std_logic_vector(12 downto 0);
signal expDiffVerySmall :  std_logic;
signal tmpExpComp2 :  std_logic_vector(12 downto 0);
signal expDiffSmall, expDiffSmall_d1 :  std_logic;
signal tmpExpComp3 :  std_logic_vector(12 downto 0);
signal expDiffNotLarge :  std_logic;
signal ShiftValue, ShiftValue_d1 :  std_logic_vector(7 downto 0);
signal CsigShifted :  std_logic_vector(215 downto 0);
signal sticky1, sticky1_d1, sticky1_d2 :  std_logic;
signal CsigShiftedT :  std_logic_vector(162 downto 0);
signal P :  std_logic_vector(105 downto 0);
signal Paligned, Paligned_d1 :  std_logic_vector(162 downto 0);
signal CsigInverted :  std_logic_vector(163 downto 0);
signal BigSum :  std_logic_vector(163 downto 0);
signal BigSum2 :  std_logic_vector(163 downto 0);
signal RsgnTentative :  std_logic;
signal BigSumAbs :  std_logic_vector(162 downto 0);
signal BigSumAbsLowerBits :  std_logic_vector(109 downto 0);
signal L :  std_logic_vector(6 downto 0);
signal tmpExpCompRes1, tmpExpCompRes1_d1 :  std_logic_vector(12 downto 0);
signal tmpExpCompRes2 :  std_logic_vector(12 downto 0);
signal RisSubNormal, RisSubNormal_d1, RisSubNormal_d2 :  std_logic;
signal RisZero, RisZero_d1, RisZero_d2 :  std_logic;
signal RisSubNormalOrZero :  std_logic;
signal Rsgn, Rsgn_d1, Rsgn_d2 :  std_logic;
signal shiftValueCaseSubnormal, shiftValueCaseSubnormal_d1 :  std_logic_vector(11 downto 0);
signal normShiftValue :  std_logic_vector(7 downto 0);
signal BigSumNormd :  std_logic_vector(324 downto 0);
signal expTentative, expTentative_d1, expTentative_d2 :  std_logic_vector(12 downto 0);
signal sticky2 :  std_logic;
signal fracTentative :  std_logic_vector(55 downto 0);
signal fracLeadingBitsNormal :  std_logic_vector(1 downto 0);
signal fracLeadingBits :  std_logic_vector(1 downto 0);
signal fracResultNormd :  std_logic_vector(51 downto 0);
signal fracResultRoundBit :  std_logic;
signal fracResultStickyBit :  std_logic;
signal round :  std_logic;
signal expUpdate :  std_logic_vector(12 downto 0);
signal exponentResult1 :  std_logic_vector(12 downto 0);
signal resultBeforeRound :  std_logic_vector(64 downto 0);
signal resultRounded :  std_logic_vector(64 downto 0);
signal Roverflowed :  std_logic;
signal finalRisInf :  std_logic;
signal Inf, Inf_d1, Inf_d2, Inf_d3 :  std_logic_vector(62 downto 0);
signal NaN, NaN_d1, NaN_d2, NaN_d3 :  std_logic_vector(62 downto 0);
signal negateAB_d1 :  std_logic;
signal negateC_d1 :  std_logic;
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            Asgn_d1 <=  Asgn;
            AisZero_d1 <=  AisZero;
            Bsgn_d1 <=  Bsgn;
            BisZero_d1 <=  BisZero;
            AexpPlusBexp_d1 <=  AexpPlusBexp;
            Csgn_d1 <=  Csgn;
            CisNormal_d1 <=  CisNormal;
            CisZero_d1 <=  CisZero;
            RisNaN_d1 <=  RisNaN;
            RisNaN_d2 <=  RisNaN_d1;
            RisNaN_d3 <=  RisNaN_d2;
            tentativeRisInf_d1 <=  tentativeRisInf;
            tentativeRisInf_d2 <=  tentativeRisInf_d1;
            tentativeRisInf_d3 <=  tentativeRisInf_d2;
            Cexp_d1 <=  Cexp;
            effectiveSub_d1 <=  effectiveSub;
            expDiffSmall_d1 <=  expDiffSmall;
            ShiftValue_d1 <=  ShiftValue;
            sticky1_d1 <=  sticky1;
            sticky1_d2 <=  sticky1_d1;
            Paligned_d1 <=  Paligned;
            tmpExpCompRes1_d1 <=  tmpExpCompRes1;
            RisSubNormal_d1 <=  RisSubNormal;
            RisSubNormal_d2 <=  RisSubNormal_d1;
            RisZero_d1 <=  RisZero;
            RisZero_d2 <=  RisZero_d1;
            Rsgn_d1 <=  Rsgn;
            Rsgn_d2 <=  Rsgn_d1;
            shiftValueCaseSubnormal_d1 <=  shiftValueCaseSubnormal;
            expTentative_d1 <=  expTentative;
            expTentative_d2 <=  expTentative_d1;
            Inf_d1 <=  Inf;
            Inf_d2 <=  Inf_d1;
            Inf_d3 <=  Inf_d2;
            NaN_d1 <=  NaN;
            NaN_d2 <=  NaN_d1;
            NaN_d3 <=  NaN_d2;
            negateAB_d1 <=  negateAB;
            negateC_d1 <=  negateC;
         end if;
      end process;

    -- Input decomposition 
   Asgn <= A(63);
   AexpField <= A(62 downto 52);
   AsigField <= A(51 downto 0);
   AisNormal <= A(52) or A(53) or A(54) or A(55) or A(56) or A(57) or A(58) or A(59) or A(60) or A(61) or A(62);
   AisInfOrNaN <= A(52) and A(53) and A(54) and A(55) and A(56) and A(57) and A(58) and A(59) and A(60) and A(61) and A(62);
   AhasNonNullSig <= A(0) or A(1) or A(2) or A(3) or A(4) or A(5) or A(6) or A(7) or A(8) or A(9) or A(10) or A(11) or A(12) or A(13) or A(14) or A(15) or A(16) or A(17) or A(18) or A(19) or A(20) or A(21) or A(22) or A(23) or A(24) or A(25) or A(26) or A(27) or A(28) or A(29) or A(30) or A(31) or A(32) or A(33) or A(34) or A(35) or A(36) or A(37) or A(38) or A(39) or A(40) or A(41) or A(42) or A(43) or A(44) or A(45) or A(46) or A(47) or A(48) or A(49) or A(50) or A(51);
   AisZero <= (not AisNormal) and not AhasNonNullSig;
   AisInf <= AisInfOrNaN and not AhasNonNullSig;
   AisNaN <= AisInfOrNaN and AhasNonNullSig;
   Bsgn <= B(63);
   BexpField <= B(62 downto 52);
   BsigField <= B(51 downto 0);
   BisNormal <= B(52) or B(53) or B(54) or B(55) or B(56) or B(57) or B(58) or B(59) or B(60) or B(61) or B(62);
   BisInfOrNaN <= B(52) and B(53) and B(54) and B(55) and B(56) and B(57) and B(58) and B(59) and B(60) and B(61) and B(62);
   BhasNonNullSig <= B(0) or B(1) or B(2) or B(3) or B(4) or B(5) or B(6) or B(7) or B(8) or B(9) or B(10) or B(11) or B(12) or B(13) or B(14) or B(15) or B(16) or B(17) or B(18) or B(19) or B(20) or B(21) or B(22) or B(23) or B(24) or B(25) or B(26) or B(27) or B(28) or B(29) or B(30) or B(31) or B(32) or B(33) or B(34) or B(35) or B(36) or B(37) or B(38) or B(39) or B(40) or B(41) or B(42) or B(43) or B(44) or B(45) or B(46) or B(47) or B(48) or B(49) or B(50) or B(51);
   BisZero <= (not BisNormal) and not BhasNonNullSig;
   BisInf <= BisInfOrNaN and not BhasNonNullSig;
   BisNaN <= BisInfOrNaN and BhasNonNullSig;

   -- unbiased exponents make everything simpler but may lead to suboptimal arch 
   Aexp <= AexpField - ("0" & (9 downto 1 => '1') & AisNormal);
   Bexp <= BexpField - ("0" & (9 downto 1 => '1') & BisNormal);

   -- mantissa with the implicit 1 or 0 appended 
   Asig <= AisNormal & AsigField ;
   Bsig <= BisNormal & BsigField ;
   AexpPlusBexp <= (Aexp(10) & Aexp) + (Bexp(10) & Bexp) ;
   Csgn <= C(63);
   CexpField <= C(62 downto 52);
   CsigField <= C(51 downto 0);
   CisNormal <= C(52) or C(53) or C(54) or C(55) or C(56) or C(57) or C(58) or C(59) or C(60) or C(61) or C(62);
   CisInfOrNaN <= C(52) and C(53) and C(54) and C(55) and C(56) and C(57) and C(58) and C(59) and C(60) and C(61) and C(62);
   ChasNonNullSig <= C(0) or C(1) or C(2) or C(3) or C(4) or C(5) or C(6) or C(7) or C(8) or C(9) or C(10) or C(11) or C(12) or C(13) or C(14) or C(15) or C(16) or C(17) or C(18) or C(19) or C(20) or C(21) or C(22) or C(23) or C(24) or C(25) or C(26) or C(27) or C(28) or C(29) or C(30) or C(31) or C(32) or C(33) or C(34) or C(35) or C(36) or C(37) or C(38) or C(39) or C(40) or C(41) or C(42) or C(43) or C(44) or C(45) or C(46) or C(47) or C(48) or C(49) or C(50) or C(51);
   CisZero <= (not CisNormal) and not ChasNonNullSig;
   CisInf <= CisInfOrNaN and not ChasNonNullSig;
   CisNaN <= CisInfOrNaN and ChasNonNullSig;
   -- result NaN iff one input is NaN, or 0*inf+x, or +/-(inf-inf)
   -- not tentative: the last case may not happen for finite A and B and inf C, as in this case AB remains finite
   RisNaN <= AisNaN or BisNaN or CisNaN or ((AisInf or BisInf) and CisInf and ((Asgn xor Bsgn) xor Csgn));
   -- result inf iff either AB or C is inf, and both have the same sign
   -- tentative, AB+C may overflow
   tentativeRisInf <= (((AisInf and not (BisZero or BisNaN)) or (BisInf and not (AisZero or AisNaN))) and (not CisNaN) and ((CisInf and not ((Asgn xor Bsgn) xor Csgn)) or not CisInf))
      or (CisInf and (not (AisNaN or BisNaN)) and (((AisInf or BisInf) and not ((Asgn xor Bsgn) xor Csgn)) or not (AisInf or BisInf)));

   -- unbiased exponents make everything simpler but may lead to suboptimal arch 
   Cexp <= CexpField - ("0" & (9 downto 1 => '1') & CisNormal);
   effectiveSub <= (negateAB xor Asgn xor Bsgn) xor (negateC xor Csgn);

   -- mantissa with the implicit 1 or 0 appended 
   Csig <= CisNormal & CsigField ;

    -- Computation of the exponent difference 
   expDiffPrepare <= ("00" & AexpField) + ("00" & BexpField) - ("000" & (9 downto 1 => '1') & AisNormal) - BisNormal;
   expDiff <= ("00" & CexpField) - expDiffPrepare - CisNormal;

    -- Addend shift datapath 
   -- Some logic to determine shift distance and tentative result exponent 
   tmpExpComp1 <= expDiff + "0000001101010";
   expDiffVerySmall <= tmpExpComp1(12);  -- if expDiff < -2p
   tmpExpComp2 <= expDiff - "0000000000011";
   expDiffSmall <= tmpExpComp2(12);  -- if expDiff < 3
   tmpExpComp3 <= expDiff - "0000000111000";
   expDiffNotLarge <= tmpExpComp3(12);  -- if expDiff < p+3
   ShiftValue <= 
           "10100011" when expDiffVerySmall='1'
      else "00111000" - (expDiff (7 downto 0)) when expDiffNotLarge='1'
      else "00000000" ;
   RightShifterComponent: RightShifter53_by_max_163_F100_uid4
      port map ( clk  => clk,
                 S => ShiftValue,
                 X => Csig,
                 R => CsigShifted);
   sticky1 <= CsigShifted(0) or CsigShifted(1) or CsigShifted(2) or CsigShifted(3) or CsigShifted(4) or CsigShifted(5) or CsigShifted(6) or CsigShifted(7) or CsigShifted(8) or CsigShifted(9) or CsigShifted(10) or CsigShifted(11) or CsigShifted(12) or CsigShifted(13) or CsigShifted(14) or CsigShifted(15) or CsigShifted(16) or CsigShifted(17) or CsigShifted(18) or CsigShifted(19) or CsigShifted(20) or CsigShifted(21) or CsigShifted(22) or CsigShifted(23) or CsigShifted(24) or CsigShifted(25) or CsigShifted(26) or CsigShifted(27) or CsigShifted(28) or CsigShifted(29) or CsigShifted(30) or CsigShifted(31) or CsigShifted(32) or CsigShifted(33) or CsigShifted(34) or CsigShifted(35) or CsigShifted(36) or CsigShifted(37) or CsigShifted(38) or CsigShifted(39) or CsigShifted(40) or CsigShifted(41) or CsigShifted(42) or CsigShifted(43) or CsigShifted(44) or CsigShifted(45) or CsigShifted(46) or CsigShifted(47) or CsigShifted(48) or CsigShifted(49) or CsigShifted(50) or CsigShifted(51) or CsigShifted(52);
   CsigShiftedT <= CsigShifted(215 downto 53);

    -- Product datapath (using naive * operator, may improve in the future)
   P <= Asig * Bsig ;
   Paligned <= (54 downto 0 => '0') & P & "00";

    -- The sum at last 
   CsigInverted <= ('0' &CsigShiftedT) when effectiveSub_d1='0'  else ('1' & not CsigShiftedT);
   BigSum <= CsigInverted + ('0' & Paligned_d1) + effectiveSub_d1;  -- P +/-CeffectiveSub is a carry in
   BigSum2 <= CsigShiftedT - ('0' & Paligned_d1);
   RsgnTentative <= Asgn_d1 xor Bsgn_d1 xor negateAB_d1 xor BigSum(163);
   BigSumAbs <= BigSum(162 downto 0) when (BigSum2(163) or not effectiveSub_d1)='1' else BigSum2(162 downto 0);
   BigSumAbsLowerBits <= BigSumAbs(109 downto 0);
   IEEEFMA_11_52_F100_uid2LeadingZeroCounter: LZC_110_F100_uid6
      port map ( clk  => clk,
                 I => BigSumAbsLowerBits,
                 O => L);
   tmpExpCompRes1 <= (AexpPlusBexp(11) & AexpPlusBexp) + "0010000000001";
   tmpExpCompRes2 <= tmpExpCompRes1_d1 - ((12 downto 7 => '0') & L);
   RisSubNormal <= (expDiffSmall_d1 or not CisNormal_d1) and  tmpExpCompRes2(12);
   RisZero <= expDiffSmall_d1 when L="1101110"  else '0';
   RisSubNormalOrZero <= RisSubNormal or RisZero;
   Rsgn <=      (Asgn_d1 xor Bsgn_d1 xor negateAB_d1) and (Csgn_d1 xor negateC_d1) when ((AisZero_d1 or BisZero_d1) and CisZero_d1)='1'  -- negative only for -0 + -0 
      else '0' when RisZero='1'  -- covers 1-1 = +0
      else RsgnTentative;  -- covers to underflow to zero case
   shiftValueCaseSubnormal <= AexpPlusBexp + "010000110110";
   normShiftValue <= 
           L + "00110110" when (expDiffSmall_d1 and not RisSubNormal)='1'
      else shiftValueCaseSubnormal_d1(7 downto 0) when (expDiffSmall_d1 and RisSubNormal)='1'
      else ShiftValue_d1; -- undo inital shift
   NormalizationShifter: LeftShifter163_by_max_162_F100_uid8
      port map ( clk  => clk,
                 S => normShiftValue,
                 X => BigSumAbs,
                 R => BigSumNormd);
   -- TODO opt: push all the constant additions to exponentUpdate
   expTentative <= 
           "1110000000011" when RisZero='1'
      else "1110000000010" when RisSubNormal='1'
      else (AexpPlusBexp_d1(11) & AexpPlusBexp_d1 - ((12 downto 7 => '0') & L))  + "0000000000011" when (expDiffSmall_d1 and not RisSubNormal)='1'
      else (Cexp_d1(10) & Cexp_d1(10) & Cexp_d1) + "0000000000001" ;
   sticky2 <= BigSumNormd(0) or BigSumNormd(1) or BigSumNormd(2) or BigSumNormd(3) or BigSumNormd(4) or BigSumNormd(5) or BigSumNormd(6) or BigSumNormd(7) or BigSumNormd(8) or BigSumNormd(9) or BigSumNormd(10) or BigSumNormd(11) or BigSumNormd(12) or BigSumNormd(13) or BigSumNormd(14) or BigSumNormd(15) or BigSumNormd(16) or BigSumNormd(17) or BigSumNormd(18) or BigSumNormd(19) or BigSumNormd(20) or BigSumNormd(21) or BigSumNormd(22) or BigSumNormd(23) or BigSumNormd(24) or BigSumNormd(25) or BigSumNormd(26) or BigSumNormd(27) or BigSumNormd(28) or BigSumNormd(29) or BigSumNormd(30) or BigSumNormd(31) or BigSumNormd(32) or BigSumNormd(33) or BigSumNormd(34) or BigSumNormd(35) or BigSumNormd(36) or BigSumNormd(37) or BigSumNormd(38) or BigSumNormd(39) or BigSumNormd(40) or BigSumNormd(41) or BigSumNormd(42) or BigSumNormd(43) or BigSumNormd(44) or BigSumNormd(45) or BigSumNormd(46) or BigSumNormd(47) or BigSumNormd(48) or BigSumNormd(49) or BigSumNormd(50) or BigSumNormd(51) or BigSumNormd(52) or BigSumNormd(53) or BigSumNormd(54) or BigSumNormd(55) or BigSumNormd(56) or BigSumNormd(57) or BigSumNormd(58) or BigSumNormd(59) or BigSumNormd(60) or BigSumNormd(61) or BigSumNormd(62) or BigSumNormd(63) or BigSumNormd(64) or BigSumNormd(65) or BigSumNormd(66) or BigSumNormd(67) or BigSumNormd(68) or BigSumNormd(69) or BigSumNormd(70) or BigSumNormd(71) or BigSumNormd(72) or BigSumNormd(73) or BigSumNormd(74) or BigSumNormd(75) or BigSumNormd(76) or BigSumNormd(77) or BigSumNormd(78) or BigSumNormd(79) or BigSumNormd(80) or BigSumNormd(81) or BigSumNormd(82) or BigSumNormd(83) or BigSumNormd(84) or BigSumNormd(85) or BigSumNormd(86) or BigSumNormd(87) or BigSumNormd(88) or BigSumNormd(89) or BigSumNormd(90) or BigSumNormd(91) or BigSumNormd(92) or BigSumNormd(93) or BigSumNormd(94) or BigSumNormd(95) or BigSumNormd(96) or BigSumNormd(97) or BigSumNormd(98) or BigSumNormd(99) or BigSumNormd(100) or BigSumNormd(101) or BigSumNormd(102) or BigSumNormd(103) or BigSumNormd(104) or BigSumNormd(105) or BigSumNormd(106) or BigSumNormd(107);

   fracTentative <= BigSumNormd(163 downto 108);

    -- Last 2-bit normalization 
   fracLeadingBitsNormal <=  fracTentative(55 downto 54) ;
   fracLeadingBits <= "01" when RisSubNormal_d2='1' else  fracLeadingBitsNormal;
   fracResultNormd <=
           fracTentative(52 downto 1)  when fracLeadingBits = "00" 
      else fracTentative(53 downto 2)  when fracLeadingBits = "01" 
      else fracTentative(54 downto 3);
   fracResultRoundBit <=
           fracTentative(0) 	 when fracLeadingBits = "00" 
      else fracTentative(1)    when fracLeadingBits = "01" 
      else fracTentative(2) ;
   fracResultStickyBit <=
           sticky1_d2 or sticky2	 when fracLeadingBits = "00" 
      else fracTentative(0) or sticky1_d2 or sticky2    when fracLeadingBits = "01" 
      else fracTentative(1) or fracTentative(0) or  sticky1_d2 or sticky2;
   round <= fracResultRoundBit and (fracResultStickyBit or fracResultNormd(0));
   expUpdate <= "0001111111101" when RisZero_d2 = '1'       -- bias - 2
         else   "0001111111101" when fracLeadingBits = "00" -- bias - 2
         else   "0001111111110" when fracLeadingBits = "01" -- bias - 1 
         else   "0001111111111";                            -- bias 
   exponentResult1 <= expTentative_d2 + expUpdate;
   resultBeforeRound <= exponentResult1 & fracResultNormd;
   resultRounded <= resultBeforeRound + ((64 downto 1 => '0') & round);
   Roverflowed <= resultRounded(64) or resultRounded(63) or (resultRounded(62) and resultRounded(61) and resultRounded(60) and resultRounded(59) and resultRounded(58) and resultRounded(57) and resultRounded(56) and resultRounded(55) and resultRounded(54) and resultRounded(53) and resultRounded(52));
   finalRisInf <= tentativeRisInf_d3 or Roverflowed; 
   Inf <= (62 downto 52 => '1') & (51 downto 0 => '0');
   NaN <= (62 downto 52 => '1') & (51 downto 0 => '1');
   R <= 
           Rsgn_d2 & Inf_d3 when ((not RisNaN_d3) and finalRisInf)='1'
      else '0'  & NaN_d3 when RisNaN_d3='1'
      else Rsgn_d2 & resultRounded(62 downto 0);
end architecture;

