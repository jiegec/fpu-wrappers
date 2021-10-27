--------------------------------------------------------------------------------
--                     RightShifter11_by_max_37_F250_uid4
-- VHDL generated for Kintex7 @ 250MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2008-2011), Florent de Dinechin (2008-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 0 cycles
-- Clock period (ns): 4
-- Target frequency (MHz): 250
-- Input signals: X S
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;
library std;
use std.textio.all;
library work;

entity RightShifter11_by_max_37_F250_uid4 is
    port (clk : in std_logic;
          X : in  std_logic_vector(10 downto 0);
          S : in  std_logic_vector(5 downto 0);
          R : out  std_logic_vector(47 downto 0)   );
end entity;

architecture arch of RightShifter11_by_max_37_F250_uid4 is
signal ps :  std_logic_vector(5 downto 0);
signal level0 :  std_logic_vector(10 downto 0);
signal level1 :  std_logic_vector(11 downto 0);
signal level2 :  std_logic_vector(13 downto 0);
signal level3 :  std_logic_vector(17 downto 0);
signal level4 :  std_logic_vector(25 downto 0);
signal level5 :  std_logic_vector(41 downto 0);
signal level6 :  std_logic_vector(73 downto 0);
begin
   ps<= S;
   level0<= X;
   level1 <=  (0 downto 0 => '0') & level0 when ps(0) = '1' else    level0 & (0 downto 0 => '0');
   R <= level6(73 downto 26);
   level2 <=  (1 downto 0 => '0') & level1 when ps(1) = '1' else    level1 & (1 downto 0 => '0');
   R <= level6(73 downto 26);
   level3 <=  (3 downto 0 => '0') & level2 when ps(2) = '1' else    level2 & (3 downto 0 => '0');
   R <= level6(73 downto 26);
   level4 <=  (7 downto 0 => '0') & level3 when ps(3) = '1' else    level3 & (7 downto 0 => '0');
   R <= level6(73 downto 26);
   level5 <=  (15 downto 0 => '0') & level4 when ps(4) = '1' else    level4 & (15 downto 0 => '0');
   R <= level6(73 downto 26);
   level6 <=  (31 downto 0 => '0') & level5 when ps(5) = '1' else    level5 & (31 downto 0 => '0');
   R <= level6(73 downto 26);
end architecture;

--------------------------------------------------------------------------------
--                              LZC_26_F250_uid6
-- VHDL generated for Kintex7 @ 250MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, Bogdan Pasca (2007)
--------------------------------------------------------------------------------
-- Pipeline depth: 1 cycles
-- Clock period (ns): 4
-- Target frequency (MHz): 250
-- Input signals: I
-- Output signals: O

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;
library std;
use std.textio.all;
library work;

entity LZC_26_F250_uid6 is
    port (clk : in std_logic;
          I : in  std_logic_vector(25 downto 0);
          O : out  std_logic_vector(4 downto 0)   );
end entity;

architecture arch of LZC_26_F250_uid6 is
signal level5, level5_d1 :  std_logic_vector(30 downto 0);
signal digit4 :  std_logic;
signal level4 :  std_logic_vector(14 downto 0);
signal digit3 :  std_logic;
signal level3 :  std_logic_vector(6 downto 0);
signal digit2 :  std_logic;
signal level2 :  std_logic_vector(2 downto 0);
signal lowBits :  std_logic_vector(1 downto 0);
signal outHighBits :  std_logic_vector(2 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            level5_d1 <=  level5;
         end if;
      end process;
   -- pad input to the next power of two minus 1
   level5 <= I & "11111";
   -- Main iteration for large inputs
   digit4<= '1' when level5_d1(30 downto 15) = "0000000000000000" else '0';
   level4<= level5_d1(14 downto 0) when digit4='1' else level5_d1(30 downto 16);
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
   outHighBits <= digit4 & digit3 & digit2 & "";
   O <= outHighBits & lowBits ;
end architecture;

--------------------------------------------------------------------------------
--                     LeftShifter37_by_max_36_F250_uid8
-- VHDL generated for Kintex7 @ 250MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2008-2011), Florent de Dinechin (2008-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 2 cycles
-- Clock period (ns): 4
-- Target frequency (MHz): 250
-- Input signals: X S
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;
library std;
use std.textio.all;
library work;

entity LeftShifter37_by_max_36_F250_uid8 is
    port (clk : in std_logic;
          X : in  std_logic_vector(36 downto 0);
          S : in  std_logic_vector(5 downto 0);
          R : out  std_logic_vector(72 downto 0)   );
end entity;

architecture arch of LeftShifter37_by_max_36_F250_uid8 is
signal ps, ps_d1, ps_d2 :  std_logic_vector(5 downto 0);
signal level0, level0_d1 :  std_logic_vector(36 downto 0);
signal level1, level1_d1 :  std_logic_vector(37 downto 0);
signal level2 :  std_logic_vector(39 downto 0);
signal level3 :  std_logic_vector(43 downto 0);
signal level4 :  std_logic_vector(51 downto 0);
signal level5, level5_d1 :  std_logic_vector(67 downto 0);
signal level6 :  std_logic_vector(99 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            ps_d1 <=  ps;
            ps_d2 <=  ps_d1;
            level0_d1 <=  level0;
            level1_d1 <=  level1;
            level5_d1 <=  level5;
         end if;
      end process;
   ps<= S;
   level0<= X;
   level1<= level0_d1 & (0 downto 0 => '0') when ps(0)= '1' else     (0 downto 0 => '0') & level0_d1;
   R <= level6(72 downto 0);
   level2<= level1_d1 & (1 downto 0 => '0') when ps_d1(1)= '1' else     (1 downto 0 => '0') & level1_d1;
   R <= level6(72 downto 0);
   level3<= level2 & (3 downto 0 => '0') when ps_d1(2)= '1' else     (3 downto 0 => '0') & level2;
   R <= level6(72 downto 0);
   level4<= level3 & (7 downto 0 => '0') when ps_d1(3)= '1' else     (7 downto 0 => '0') & level3;
   R <= level6(72 downto 0);
   level5<= level4 & (15 downto 0 => '0') when ps_d1(4)= '1' else     (15 downto 0 => '0') & level4;
   R <= level6(72 downto 0);
   level6<= level5_d1 & (31 downto 0 => '0') when ps_d2(5)= '1' else     (31 downto 0 => '0') & level5_d1;
   R <= level6(72 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                                   FMA_H
--                          (IEEEFMA_5_10_F250_uid2)
-- Inputs: this FMA computes A*B+C
-- VHDL generated for Kintex7 @ 250MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin (2009-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 3 cycles
-- Clock period (ns): 4
-- Target frequency (MHz): 250
-- Input signals: A B C negateAB negateC RndMode
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.numeric_std_unsigned.all;
library std;
use std.textio.all;
library work;

entity FMA_H is
    port (clk : in std_logic;
          A : in  std_logic_vector(15 downto 0);
          B : in  std_logic_vector(15 downto 0);
          C : in  std_logic_vector(15 downto 0);
          negateAB : in  std_logic;
          negateC : in  std_logic;
          RndMode : in  std_logic_vector(1 downto 0);
          R : out  std_logic_vector(15 downto 0)   );
end entity;

architecture arch of FMA_H is
   component RightShifter11_by_max_37_F250_uid4 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(10 downto 0);
             S : in  std_logic_vector(5 downto 0);
             R : out  std_logic_vector(47 downto 0)   );
   end component;

   component LZC_26_F250_uid6 is
      port ( clk : in std_logic;
             I : in  std_logic_vector(25 downto 0);
             O : out  std_logic_vector(4 downto 0)   );
   end component;

   component LeftShifter37_by_max_36_F250_uid8 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(36 downto 0);
             S : in  std_logic_vector(5 downto 0);
             R : out  std_logic_vector(72 downto 0)   );
   end component;

signal Asgn, Asgn_d1 :  std_logic;
signal AexpField :  std_logic_vector(4 downto 0);
signal AsigField :  std_logic_vector(9 downto 0);
signal AisNormal :  std_logic;
signal AisInfOrNaN :  std_logic;
signal AhasNonNullSig :  std_logic;
signal AisZero, AisZero_d1 :  std_logic;
signal AisInf :  std_logic;
signal AisNaN :  std_logic;
signal Bsgn, Bsgn_d1 :  std_logic;
signal BexpField :  std_logic_vector(4 downto 0);
signal BsigField :  std_logic_vector(9 downto 0);
signal BisNormal :  std_logic;
signal BisInfOrNaN :  std_logic;
signal BhasNonNullSig :  std_logic;
signal BisZero, BisZero_d1 :  std_logic;
signal BisInf :  std_logic;
signal BisNaN :  std_logic;
signal Aexp :  std_logic_vector(4 downto 0);
signal Bexp :  std_logic_vector(4 downto 0);
signal Asig :  std_logic_vector(10 downto 0);
signal Bsig :  std_logic_vector(10 downto 0);
signal AexpPlusBexp, AexpPlusBexp_d1 :  std_logic_vector(5 downto 0);
signal Csgn, Csgn_d1 :  std_logic;
signal CexpField :  std_logic_vector(4 downto 0);
signal CsigField :  std_logic_vector(9 downto 0);
signal CisNormal, CisNormal_d1 :  std_logic;
signal CisInfOrNaN :  std_logic;
signal ChasNonNullSig :  std_logic;
signal CisZero, CisZero_d1 :  std_logic;
signal CisInf :  std_logic;
signal CisNaN :  std_logic;
signal RisNaN, RisNaN_d1, RisNaN_d2, RisNaN_d3 :  std_logic;
signal tentativeRisInf, tentativeRisInf_d1, tentativeRisInf_d2, tentativeRisInf_d3 :  std_logic;
signal Cexp, Cexp_d1 :  std_logic_vector(4 downto 0);
signal effectiveSub :  std_logic;
signal Csig :  std_logic_vector(10 downto 0);
signal expDiffPrepare :  std_logic_vector(6 downto 0);
signal expDiff :  std_logic_vector(6 downto 0);
signal tmpExpComp1 :  std_logic_vector(6 downto 0);
signal expDiffVerySmall :  std_logic;
signal tmpExpComp2 :  std_logic_vector(6 downto 0);
signal expDiffSmall, expDiffSmall_d1 :  std_logic;
signal tmpExpComp3 :  std_logic_vector(6 downto 0);
signal expDiffNotLarge :  std_logic;
signal ShiftValue, ShiftValue_d1 :  std_logic_vector(5 downto 0);
signal CsigShifted :  std_logic_vector(47 downto 0);
signal sticky1, sticky1_d1, sticky1_d2, sticky1_d3 :  std_logic;
signal CsigShiftedT :  std_logic_vector(36 downto 0);
signal P :  std_logic_vector(21 downto 0);
signal Paligned :  std_logic_vector(36 downto 0);
signal CsigInverted :  std_logic_vector(37 downto 0);
signal BigSum :  std_logic_vector(37 downto 0);
signal BigSum2 :  std_logic_vector(37 downto 0);
signal RsgnTentative, RsgnTentative_d1 :  std_logic;
signal BigSumAbs :  std_logic_vector(36 downto 0);
signal BigSumAbsLowerBits :  std_logic_vector(25 downto 0);
signal L :  std_logic_vector(4 downto 0);
signal tmpExpCompRes1, tmpExpCompRes1_d1 :  std_logic_vector(6 downto 0);
signal tmpExpCompRes2 :  std_logic_vector(6 downto 0);
signal RisSubNormal, RisSubNormal_d1, RisSubNormal_d2 :  std_logic;
signal RisZero, RisZero_d1, RisZero_d2 :  std_logic;
signal RisSubNormalOrZero :  std_logic;
signal Rsgn, Rsgn_d1, Rsgn_d2 :  std_logic;
signal shiftValueCaseSubnormal, shiftValueCaseSubnormal_d1 :  std_logic_vector(5 downto 0);
signal normShiftValue :  std_logic_vector(5 downto 0);
signal BigSumNormd :  std_logic_vector(72 downto 0);
signal expTentative, expTentative_d1, expTentative_d2 :  std_logic_vector(6 downto 0);
signal sticky2 :  std_logic;
signal fracTentative :  std_logic_vector(13 downto 0);
signal fracLeadingBitsNormal :  std_logic_vector(1 downto 0);
signal fracLeadingBits :  std_logic_vector(1 downto 0);
signal fracResultNormd :  std_logic_vector(9 downto 0);
signal fracResultRoundBit :  std_logic;
signal fracResultStickyBit :  std_logic;
signal round :  std_logic;
signal expUpdate :  std_logic_vector(6 downto 0);
signal exponentResult1 :  std_logic_vector(6 downto 0);
signal resultBeforeRound :  std_logic_vector(16 downto 0);
signal resultRounded :  std_logic_vector(16 downto 0);
signal Roverflowed :  std_logic;
signal finalRisInf :  std_logic;
signal Inf, Inf_d1, Inf_d2, Inf_d3 :  std_logic_vector(14 downto 0);
signal NaN, NaN_d1, NaN_d2, NaN_d3 :  std_logic_vector(14 downto 0);
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
            expDiffSmall_d1 <=  expDiffSmall;
            ShiftValue_d1 <=  ShiftValue;
            sticky1_d1 <=  sticky1;
            sticky1_d2 <=  sticky1_d1;
            sticky1_d3 <=  sticky1_d2;
            RsgnTentative_d1 <=  RsgnTentative;
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
   Asgn <= A(15);
   AexpField <= A(14 downto 10);
   AsigField <= A(9 downto 0);
   AisNormal <= A(10) or A(11) or A(12) or A(13) or A(14);
   AisInfOrNaN <= A(10) and A(11) and A(12) and A(13) and A(14);
   AhasNonNullSig <= A(0) or A(1) or A(2) or A(3) or A(4) or A(5) or A(6) or A(7) or A(8) or A(9);
   AisZero <= (not AisNormal) and not AhasNonNullSig;
   AisInf <= AisInfOrNaN and not AhasNonNullSig;
   AisNaN <= AisInfOrNaN and AhasNonNullSig;
   Bsgn <= B(15);
   BexpField <= B(14 downto 10);
   BsigField <= B(9 downto 0);
   BisNormal <= B(10) or B(11) or B(12) or B(13) or B(14);
   BisInfOrNaN <= B(10) and B(11) and B(12) and B(13) and B(14);
   BhasNonNullSig <= B(0) or B(1) or B(2) or B(3) or B(4) or B(5) or B(6) or B(7) or B(8) or B(9);
   BisZero <= (not BisNormal) and not BhasNonNullSig;
   BisInf <= BisInfOrNaN and not BhasNonNullSig;
   BisNaN <= BisInfOrNaN and BhasNonNullSig;

   -- unbiased exponents make everything simpler but may lead to suboptimal arch 
   Aexp <= AexpField - ("0" & (3 downto 1 => '1') & AisNormal);
   Bexp <= BexpField - ("0" & (3 downto 1 => '1') & BisNormal);

   -- mantissa with the implicit 1 or 0 appended 
   Asig <= AisNormal & AsigField ;
   Bsig <= BisNormal & BsigField ;
   AexpPlusBexp <= (Aexp(4) & Aexp) + (Bexp(4) & Bexp) ;
   Csgn <= C(15);
   CexpField <= C(14 downto 10);
   CsigField <= C(9 downto 0);
   CisNormal <= C(10) or C(11) or C(12) or C(13) or C(14);
   CisInfOrNaN <= C(10) and C(11) and C(12) and C(13) and C(14);
   ChasNonNullSig <= C(0) or C(1) or C(2) or C(3) or C(4) or C(5) or C(6) or C(7) or C(8) or C(9);
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
   Cexp <= CexpField - ("0" & (3 downto 1 => '1') & CisNormal);
   effectiveSub <= (negateAB xor Asgn xor Bsgn) xor (negateC xor Csgn);

   -- mantissa with the implicit 1 or 0 appended 
   Csig <= CisNormal & CsigField ;

    -- Computation of the exponent difference 
   expDiffPrepare <= ("00" & AexpField) + ("00" & BexpField) - ("000" & (3 downto 1 => '1') & AisNormal) - BisNormal;
   expDiff <= ("00" & CexpField) - expDiffPrepare - CisNormal;

    -- Addend shift datapath 
   -- Some logic to determine shift distance and tentative result exponent 
   tmpExpComp1 <= expDiff + "0010110";
   expDiffVerySmall <= tmpExpComp1(6);  -- if expDiff < -2p
   tmpExpComp2 <= expDiff - "0000011";
   expDiffSmall <= tmpExpComp2(6);  -- if expDiff < 3
   tmpExpComp3 <= expDiff - "0001110";
   expDiffNotLarge <= tmpExpComp3(6);  -- if expDiff < p+3
   ShiftValue <= 
           "100101" when expDiffVerySmall='1'
      else "001110" - (expDiff (5 downto 0)) when expDiffNotLarge='1'
      else "000000" ;
   RightShifterComponent: RightShifter11_by_max_37_F250_uid4
      port map ( clk  => clk,
                 S => ShiftValue,
                 X => Csig,
                 R => CsigShifted);
   sticky1 <= CsigShifted(0) or CsigShifted(1) or CsigShifted(2) or CsigShifted(3) or CsigShifted(4) or CsigShifted(5) or CsigShifted(6) or CsigShifted(7) or CsigShifted(8) or CsigShifted(9) or CsigShifted(10);
   CsigShiftedT <= CsigShifted(47 downto 11);

    -- Product datapath (using naive * operator, may improve in the future)
   P <= Asig * Bsig ;
   Paligned <= (12 downto 0 => '0') & P & "00";

    -- The sum at last 
   CsigInverted <= ('0' &CsigShiftedT) when effectiveSub='0'  else ('1' & not CsigShiftedT);
   BigSum <= CsigInverted + ('0' & Paligned) + effectiveSub;  -- P +/-CeffectiveSub is a carry in
   BigSum2 <= CsigShiftedT - ('0' & Paligned);
   RsgnTentative <= Asgn xor Bsgn xor negateAB xor BigSum(37);
   BigSumAbs <= BigSum(36 downto 0) when (BigSum2(37) or not effectiveSub)='1' else BigSum2(36 downto 0);
   BigSumAbsLowerBits <= BigSumAbs(25 downto 0);
   IEEEFMA_5_10_F250_uid2LeadingZeroCounter: LZC_26_F250_uid6
      port map ( clk  => clk,
                 I => BigSumAbsLowerBits,
                 O => L);
   tmpExpCompRes1 <= (AexpPlusBexp(5) & AexpPlusBexp) + "0010001";
   tmpExpCompRes2 <= tmpExpCompRes1_d1 - ((6 downto 5 => '0') & L);
   RisSubNormal <= (expDiffSmall_d1 or not CisNormal_d1) and  tmpExpCompRes2(6);
   RisZero <= expDiffSmall_d1 when L="11010"  else '0';
   RisSubNormalOrZero <= RisSubNormal or RisZero;
   Rsgn <=      (Asgn_d1 xor Bsgn_d1 xor negateAB_d1) and (Csgn_d1 xor negateC_d1) when ((AisZero_d1 or BisZero_d1) and CisZero_d1)='1'  -- negative only for -0 + -0 
      else '0' when RisZero='1'  -- covers 1-1 = +0
      else RsgnTentative_d1;  -- covers to underflow to zero case
   shiftValueCaseSubnormal <= AexpPlusBexp + "011100";
   normShiftValue <= 
           L + "001100" when (expDiffSmall_d1 and not RisSubNormal)='1'
      else shiftValueCaseSubnormal_d1(5 downto 0) when (expDiffSmall_d1 and RisSubNormal)='1'
      else ShiftValue_d1; -- undo inital shift
   NormalizationShifter: LeftShifter37_by_max_36_F250_uid8
      port map ( clk  => clk,
                 S => normShiftValue,
                 X => BigSumAbs,
                 R => BigSumNormd);
   -- TODO opt: push all the constant additions to exponentUpdate
   expTentative <= 
           "1110011" when RisZero='1'
      else "1110010" when RisSubNormal='1'
      else (AexpPlusBexp_d1(5) & AexpPlusBexp_d1 - ((6 downto 5 => '0') & L))  + "0000011" when (expDiffSmall_d1 and not RisSubNormal)='1'
      else (Cexp_d1(4) & Cexp_d1(4) & Cexp_d1) + "0000001" ;
   sticky2 <= BigSumNormd(0) or BigSumNormd(1) or BigSumNormd(2) or BigSumNormd(3) or BigSumNormd(4) or BigSumNormd(5) or BigSumNormd(6) or BigSumNormd(7) or BigSumNormd(8) or BigSumNormd(9) or BigSumNormd(10) or BigSumNormd(11) or BigSumNormd(12) or BigSumNormd(13) or BigSumNormd(14) or BigSumNormd(15) or BigSumNormd(16) or BigSumNormd(17) or BigSumNormd(18) or BigSumNormd(19) or BigSumNormd(20) or BigSumNormd(21) or BigSumNormd(22) or BigSumNormd(23);

   fracTentative <= BigSumNormd(37 downto 24);

    -- Last 2-bit normalization 
   fracLeadingBitsNormal <=  fracTentative(13 downto 12) ;
   fracLeadingBits <= "01" when RisSubNormal_d2='1' else  fracLeadingBitsNormal;
   fracResultNormd <=
           fracTentative(10 downto 1)  when fracLeadingBits = "00" 
      else fracTentative(11 downto 2)  when fracLeadingBits = "01" 
      else fracTentative(12 downto 3);
   fracResultRoundBit <=
           fracTentative(0) 	 when fracLeadingBits = "00" 
      else fracTentative(1)    when fracLeadingBits = "01" 
      else fracTentative(2) ;
   fracResultStickyBit <=
           sticky1_d3 or sticky2	 when fracLeadingBits = "00" 
      else fracTentative(0) or sticky1_d3 or sticky2    when fracLeadingBits = "01" 
      else fracTentative(1) or fracTentative(0) or  sticky1_d3 or sticky2;
   round <= fracResultRoundBit and (fracResultStickyBit or fracResultNormd(0));
   expUpdate <= "0001101" when RisZero_d2 = '1'       -- bias - 2
         else   "0001101" when fracLeadingBits = "00" -- bias - 2
         else   "0001110" when fracLeadingBits = "01" -- bias - 1 
         else   "0001111";                            -- bias 
   exponentResult1 <= expTentative_d2 + expUpdate;
   resultBeforeRound <= exponentResult1 & fracResultNormd;
   resultRounded <= resultBeforeRound + ((16 downto 1 => '0') & round);
   Roverflowed <= resultRounded(16) or resultRounded(15) or (resultRounded(14) and resultRounded(13) and resultRounded(12) and resultRounded(11) and resultRounded(10));
   finalRisInf <= tentativeRisInf_d3 or Roverflowed; 
   Inf <= (14 downto 10 => '1') & (9 downto 0 => '0');
   NaN <= (14 downto 10 => '1') & (9 downto 0 => '1');
   R <= 
           Rsgn_d2 & Inf_d3 when ((not RisNaN_d3) and finalRisInf)='1'
      else '0'  & NaN_d3 when RisNaN_d3='1'
      else Rsgn_d2 & resultRounded(14 downto 0);
end architecture;

