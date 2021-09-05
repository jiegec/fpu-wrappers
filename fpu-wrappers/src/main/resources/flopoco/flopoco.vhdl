--------------------------------------------------------------------------------
--                    RightShifter53_by_max_163_F400_uid4
-- VHDL generated for Kintex7 @ 400MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2008-2011), Florent de Dinechin (2008-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 4 cycles
-- Clock period (ns): 2.5
-- Target frequency (MHz): 400
-- Input signals: X S
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity RightShifter53_by_max_163_F400_uid4 is
    port (clk : in std_logic;
          X : in  std_logic_vector(52 downto 0);
          S : in  std_logic_vector(7 downto 0);
          R : out  std_logic_vector(215 downto 0)   );
end entity;

architecture arch of RightShifter53_by_max_163_F400_uid4 is
signal ps, ps_d1, ps_d2, ps_d3, ps_d4 :  std_logic_vector(7 downto 0);
signal level0 :  std_logic_vector(52 downto 0);
signal level1 :  std_logic_vector(53 downto 0);
signal level2 :  std_logic_vector(55 downto 0);
signal level3, level3_d1 :  std_logic_vector(59 downto 0);
signal level4 :  std_logic_vector(67 downto 0);
signal level5, level5_d1 :  std_logic_vector(83 downto 0);
signal level6 :  std_logic_vector(115 downto 0);
signal level7, level7_d1, level7_d2 :  std_logic_vector(179 downto 0);
signal level8 :  std_logic_vector(307 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            ps_d1 <=  ps;
            ps_d2 <=  ps_d1;
            ps_d3 <=  ps_d2;
            ps_d4 <=  ps_d3;
            level3_d1 <=  level3;
            level5_d1 <=  level5;
            level7_d1 <=  level7;
            level7_d2 <=  level7_d1;
         end if;
      end process;
   ps<= S;
   level0<= X;
   level1 <=  (0 downto 0 => '0') & level0 when ps(0) = '1' else    level0 & (0 downto 0 => '0');
   R <= level8(307 downto 92);
   level2 <=  (1 downto 0 => '0') & level1 when ps(1) = '1' else    level1 & (1 downto 0 => '0');
   R <= level8(307 downto 92);
   level3 <=  (3 downto 0 => '0') & level2 when ps(2) = '1' else    level2 & (3 downto 0 => '0');
   R <= level8(307 downto 92);
   level4 <=  (7 downto 0 => '0') & level3_d1 when ps_d1(3) = '1' else    level3_d1 & (7 downto 0 => '0');
   R <= level8(307 downto 92);
   level5 <=  (15 downto 0 => '0') & level4 when ps_d1(4) = '1' else    level4 & (15 downto 0 => '0');
   R <= level8(307 downto 92);
   level6 <=  (31 downto 0 => '0') & level5_d1 when ps_d2(5) = '1' else    level5_d1 & (31 downto 0 => '0');
   R <= level8(307 downto 92);
   level7 <=  (63 downto 0 => '0') & level6 when ps_d2(6) = '1' else    level6 & (63 downto 0 => '0');
   R <= level8(307 downto 92);
   level8 <=  (127 downto 0 => '0') & level7_d2 when ps_d4(7) = '1' else    level7_d2 & (127 downto 0 => '0');
   R <= level8(307 downto 92);
end architecture;

--------------------------------------------------------------------------------
--                             LZC_110_F400_uid6
-- VHDL generated for Kintex7 @ 400MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, Bogdan Pasca (2007)
--------------------------------------------------------------------------------
-- Pipeline depth: 3 cycles
-- Clock period (ns): 2.5
-- Target frequency (MHz): 400
-- Input signals: I
-- Output signals: O

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity LZC_110_F400_uid6 is
    port (clk : in std_logic;
          I : in  std_logic_vector(109 downto 0);
          O : out  std_logic_vector(6 downto 0)   );
end entity;

architecture arch of LZC_110_F400_uid6 is
signal level7, level7_d1 :  std_logic_vector(126 downto 0);
signal digit6, digit6_d1, digit6_d2 :  std_logic;
signal level6 :  std_logic_vector(62 downto 0);
signal digit5, digit5_d1 :  std_logic;
signal level5, level5_d1 :  std_logic_vector(30 downto 0);
signal digit4, digit4_d1 :  std_logic;
signal level4 :  std_logic_vector(14 downto 0);
signal digit3 :  std_logic;
signal level3, level3_d1 :  std_logic_vector(6 downto 0);
signal digit2, digit2_d1 :  std_logic;
signal level2 :  std_logic_vector(2 downto 0);
signal lowBits :  std_logic_vector(1 downto 0);
signal outHighBits, outHighBits_d1 :  std_logic_vector(4 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            level7_d1 <=  level7;
            digit6_d1 <=  digit6;
            digit6_d2 <=  digit6_d1;
            digit5_d1 <=  digit5;
            level5_d1 <=  level5;
            digit4_d1 <=  digit4;
            level3_d1 <=  level3;
            digit2_d1 <=  digit2;
            outHighBits_d1 <=  outHighBits;
         end if;
      end process;
   -- pad input to the next power of two minus 1
   level7 <= I & "11111111111111111";
   -- Main iteration for large inputs
   digit6<= '1' when level7(126 downto 63) = "0000000000000000000000000000000000000000000000000000000000000000" else '0';
   level6<= level7_d1(62 downto 0) when digit6_d1='1' else level7_d1(126 downto 64);
   digit5<= '1' when level6(62 downto 31) = "00000000000000000000000000000000" else '0';
   level5<= level6(30 downto 0) when digit5='1' else level6(62 downto 32);
   digit4<= '1' when level5(30 downto 15) = "0000000000000000" else '0';
   level4<= level5_d1(14 downto 0) when digit4_d1='1' else level5_d1(30 downto 16);
   digit3<= '1' when level4(14 downto 7) = "00000000" else '0';
   level3<= level4(6 downto 0) when digit3='1' else level4(14 downto 8);
   digit2<= '1' when level3(6 downto 3) = "0000" else '0';
   level2<= level3_d1(2 downto 0) when digit2_d1='1' else level3_d1(6 downto 4);
   -- Finish counting with one LUT
   with level2  select  lowBits <= 
      "11" when "000",
      "10" when "001",
      "01" when "010",
      "01" when "011",
      "00" when others;
   outHighBits <= digit6_d2 & digit5_d1 & digit4_d1 & digit3 & digit2 & "";
   O <= outHighBits_d1 & lowBits ;
end architecture;

--------------------------------------------------------------------------------
--                    LeftShifter163_by_max_162_F400_uid8
-- VHDL generated for Kintex7 @ 400MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2008-2011), Florent de Dinechin (2008-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 8 cycles
-- Clock period (ns): 2.5
-- Target frequency (MHz): 400
-- Input signals: X S
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity LeftShifter163_by_max_162_F400_uid8 is
    port (clk : in std_logic;
          X : in  std_logic_vector(162 downto 0);
          S : in  std_logic_vector(7 downto 0);
          R : out  std_logic_vector(324 downto 0)   );
end entity;

architecture arch of LeftShifter163_by_max_162_F400_uid8 is
signal ps, ps_d1, ps_d2, ps_d3, ps_d4, ps_d5, ps_d6, ps_d7, ps_d8 :  std_logic_vector(7 downto 0);
signal level0, level0_d1, level0_d2, level0_d3 :  std_logic_vector(162 downto 0);
signal level1, level1_d1 :  std_logic_vector(163 downto 0);
signal level2 :  std_logic_vector(165 downto 0);
signal level3, level3_d1, level3_d2 :  std_logic_vector(169 downto 0);
signal level4 :  std_logic_vector(177 downto 0);
signal level5, level5_d1 :  std_logic_vector(193 downto 0);
signal level6 :  std_logic_vector(225 downto 0);
signal level7, level7_d1, level7_d2, level7_d3, level7_d4 :  std_logic_vector(289 downto 0);
signal level8 :  std_logic_vector(417 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            ps_d1 <=  ps;
            ps_d2 <=  ps_d1;
            ps_d3 <=  ps_d2;
            ps_d4 <=  ps_d3;
            ps_d5 <=  ps_d4;
            ps_d6 <=  ps_d5;
            ps_d7 <=  ps_d6;
            ps_d8 <=  ps_d7;
            level0_d1 <=  level0;
            level0_d2 <=  level0_d1;
            level0_d3 <=  level0_d2;
            level1_d1 <=  level1;
            level3_d1 <=  level3;
            level3_d2 <=  level3_d1;
            level5_d1 <=  level5;
            level7_d1 <=  level7;
            level7_d2 <=  level7_d1;
            level7_d3 <=  level7_d2;
            level7_d4 <=  level7_d3;
         end if;
      end process;
   ps<= S;
   level0<= X;
   level1<= level0_d3 & (0 downto 0 => '0') when ps(0)= '1' else     (0 downto 0 => '0') & level0_d3;
   R <= level8(324 downto 0);
   level2<= level1_d1 & (1 downto 0 => '0') when ps_d1(1)= '1' else     (1 downto 0 => '0') & level1_d1;
   R <= level8(324 downto 0);
   level3<= level2 & (3 downto 0 => '0') when ps_d1(2)= '1' else     (3 downto 0 => '0') & level2;
   R <= level8(324 downto 0);
   level4<= level3_d2 & (7 downto 0 => '0') when ps_d3(3)= '1' else     (7 downto 0 => '0') & level3_d2;
   R <= level8(324 downto 0);
   level5<= level4 & (15 downto 0 => '0') when ps_d3(4)= '1' else     (15 downto 0 => '0') & level4;
   R <= level8(324 downto 0);
   level6<= level5_d1 & (31 downto 0 => '0') when ps_d4(5)= '1' else     (31 downto 0 => '0') & level5_d1;
   R <= level8(324 downto 0);
   level7<= level6 & (63 downto 0 => '0') when ps_d4(6)= '1' else     (63 downto 0 => '0') & level6;
   R <= level8(324 downto 0);
   level8<= level7_d4 & (127 downto 0 => '0') when ps_d8(7)= '1' else     (127 downto 0 => '0') & level7_d4;
   R <= level8(324 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                                   FMA_D
--                         (IEEEFMA_11_52_F400_uid2)
-- Inputs: this FMA computes A*B+C
-- VHDL generated for Kintex7 @ 400MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin (2009-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 15 cycles
-- Clock period (ns): 2.5
-- Target frequency (MHz): 400
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
   component RightShifter53_by_max_163_F400_uid4 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(52 downto 0);
             S : in  std_logic_vector(7 downto 0);
             R : out  std_logic_vector(215 downto 0)   );
   end component;

   component LZC_110_F400_uid6 is
      port ( clk : in std_logic;
             I : in  std_logic_vector(109 downto 0);
             O : out  std_logic_vector(6 downto 0)   );
   end component;

   component LeftShifter163_by_max_162_F400_uid8 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(162 downto 0);
             S : in  std_logic_vector(7 downto 0);
             R : out  std_logic_vector(324 downto 0)   );
   end component;

signal Asgn, Asgn_d1, Asgn_d2, Asgn_d3, Asgn_d4, Asgn_d5, Asgn_d6, Asgn_d7 :  std_logic;
signal AexpField :  std_logic_vector(10 downto 0);
signal AsigField :  std_logic_vector(51 downto 0);
signal AisNormal :  std_logic;
signal AisInfOrNaN :  std_logic;
signal AhasNonNullSig :  std_logic;
signal AisZero, AisZero_d1, AisZero_d2, AisZero_d3, AisZero_d4, AisZero_d5, AisZero_d6, AisZero_d7 :  std_logic;
signal AisInf :  std_logic;
signal AisNaN :  std_logic;
signal Bsgn, Bsgn_d1, Bsgn_d2, Bsgn_d3, Bsgn_d4, Bsgn_d5, Bsgn_d6, Bsgn_d7 :  std_logic;
signal BexpField :  std_logic_vector(10 downto 0);
signal BsigField :  std_logic_vector(51 downto 0);
signal BisNormal :  std_logic;
signal BisInfOrNaN :  std_logic;
signal BhasNonNullSig :  std_logic;
signal BisZero, BisZero_d1, BisZero_d2, BisZero_d3, BisZero_d4, BisZero_d5, BisZero_d6, BisZero_d7 :  std_logic;
signal BisInf :  std_logic;
signal BisNaN :  std_logic;
signal Aexp :  std_logic_vector(10 downto 0);
signal Bexp :  std_logic_vector(10 downto 0);
signal Asig :  std_logic_vector(52 downto 0);
signal Bsig :  std_logic_vector(52 downto 0);
signal AexpPlusBexp, AexpPlusBexp_d1, AexpPlusBexp_d2, AexpPlusBexp_d3, AexpPlusBexp_d4, AexpPlusBexp_d5, AexpPlusBexp_d6, AexpPlusBexp_d7 :  std_logic_vector(11 downto 0);
signal Csgn, Csgn_d1, Csgn_d2, Csgn_d3, Csgn_d4, Csgn_d5, Csgn_d6, Csgn_d7 :  std_logic;
signal CexpField :  std_logic_vector(10 downto 0);
signal CsigField :  std_logic_vector(51 downto 0);
signal CisNormal, CisNormal_d1, CisNormal_d2, CisNormal_d3, CisNormal_d4, CisNormal_d5, CisNormal_d6, CisNormal_d7 :  std_logic;
signal CisInfOrNaN :  std_logic;
signal ChasNonNullSig :  std_logic;
signal CisZero, CisZero_d1, CisZero_d2, CisZero_d3, CisZero_d4, CisZero_d5, CisZero_d6, CisZero_d7 :  std_logic;
signal CisInf :  std_logic;
signal CisNaN :  std_logic;
signal RisNaN, RisNaN_d1, RisNaN_d2, RisNaN_d3, RisNaN_d4, RisNaN_d5, RisNaN_d6, RisNaN_d7, RisNaN_d8, RisNaN_d9, RisNaN_d10, RisNaN_d11, RisNaN_d12, RisNaN_d13, RisNaN_d14, RisNaN_d15 :  std_logic;
signal tentativeRisInf, tentativeRisInf_d1, tentativeRisInf_d2, tentativeRisInf_d3, tentativeRisInf_d4, tentativeRisInf_d5, tentativeRisInf_d6, tentativeRisInf_d7, tentativeRisInf_d8, tentativeRisInf_d9, tentativeRisInf_d10, tentativeRisInf_d11, tentativeRisInf_d12, tentativeRisInf_d13, tentativeRisInf_d14, tentativeRisInf_d15 :  std_logic;
signal Cexp, Cexp_d1, Cexp_d2, Cexp_d3, Cexp_d4, Cexp_d5, Cexp_d6, Cexp_d7 :  std_logic_vector(10 downto 0);
signal effectiveSub, effectiveSub_d1, effectiveSub_d2, effectiveSub_d3, effectiveSub_d4 :  std_logic;
signal Csig :  std_logic_vector(52 downto 0);
signal expDiffPrepare :  std_logic_vector(12 downto 0);
signal expDiff :  std_logic_vector(12 downto 0);
signal tmpExpComp1 :  std_logic_vector(12 downto 0);
signal expDiffVerySmall :  std_logic;
signal tmpExpComp2 :  std_logic_vector(12 downto 0);
signal expDiffSmall, expDiffSmall_d1, expDiffSmall_d2, expDiffSmall_d3, expDiffSmall_d4, expDiffSmall_d5, expDiffSmall_d6, expDiffSmall_d7 :  std_logic;
signal tmpExpComp3 :  std_logic_vector(12 downto 0);
signal expDiffNotLarge :  std_logic;
signal ShiftValue, ShiftValue_d1, ShiftValue_d2, ShiftValue_d3, ShiftValue_d4, ShiftValue_d5, ShiftValue_d6, ShiftValue_d7 :  std_logic_vector(7 downto 0);
signal CsigShifted :  std_logic_vector(215 downto 0);
signal sticky1, sticky1_d1, sticky1_d2, sticky1_d3, sticky1_d4, sticky1_d5, sticky1_d6, sticky1_d7, sticky1_d8, sticky1_d9, sticky1_d10, sticky1_d11 :  std_logic;
signal CsigShiftedT :  std_logic_vector(162 downto 0);
signal P :  std_logic_vector(105 downto 0);
signal Paligned, Paligned_d1, Paligned_d2, Paligned_d3, Paligned_d4 :  std_logic_vector(162 downto 0);
signal CsigInverted :  std_logic_vector(163 downto 0);
signal BigSum :  std_logic_vector(163 downto 0);
signal BigSum2 :  std_logic_vector(163 downto 0);
signal RsgnTentative, RsgnTentative_d1, RsgnTentative_d2, RsgnTentative_d3 :  std_logic;
signal BigSumAbs :  std_logic_vector(162 downto 0);
signal BigSumAbsLowerBits :  std_logic_vector(109 downto 0);
signal L :  std_logic_vector(6 downto 0);
signal tmpExpCompRes1, tmpExpCompRes1_d1, tmpExpCompRes1_d2, tmpExpCompRes1_d3, tmpExpCompRes1_d4, tmpExpCompRes1_d5, tmpExpCompRes1_d6, tmpExpCompRes1_d7 :  std_logic_vector(12 downto 0);
signal tmpExpCompRes2 :  std_logic_vector(12 downto 0);
signal RisSubNormal, RisSubNormal_d1, RisSubNormal_d2, RisSubNormal_d3, RisSubNormal_d4, RisSubNormal_d5, RisSubNormal_d6, RisSubNormal_d7, RisSubNormal_d8 :  std_logic;
signal RisZero, RisZero_d1, RisZero_d2, RisZero_d3, RisZero_d4, RisZero_d5, RisZero_d6, RisZero_d7, RisZero_d8 :  std_logic;
signal RisSubNormalOrZero :  std_logic;
signal Rsgn, Rsgn_d1, Rsgn_d2, Rsgn_d3, Rsgn_d4, Rsgn_d5, Rsgn_d6, Rsgn_d7, Rsgn_d8 :  std_logic;
signal shiftValueCaseSubnormal, shiftValueCaseSubnormal_d1, shiftValueCaseSubnormal_d2, shiftValueCaseSubnormal_d3, shiftValueCaseSubnormal_d4, shiftValueCaseSubnormal_d5, shiftValueCaseSubnormal_d6, shiftValueCaseSubnormal_d7 :  std_logic_vector(11 downto 0);
signal normShiftValue :  std_logic_vector(7 downto 0);
signal BigSumNormd :  std_logic_vector(324 downto 0);
signal expTentative, expTentative_d1, expTentative_d2, expTentative_d3, expTentative_d4, expTentative_d5, expTentative_d6, expTentative_d7, expTentative_d8 :  std_logic_vector(12 downto 0);
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
signal Inf, Inf_d1, Inf_d2, Inf_d3, Inf_d4, Inf_d5, Inf_d6, Inf_d7, Inf_d8, Inf_d9, Inf_d10, Inf_d11, Inf_d12, Inf_d13, Inf_d14, Inf_d15 :  std_logic_vector(62 downto 0);
signal NaN, NaN_d1, NaN_d2, NaN_d3, NaN_d4, NaN_d5, NaN_d6, NaN_d7, NaN_d8, NaN_d9, NaN_d10, NaN_d11, NaN_d12, NaN_d13, NaN_d14, NaN_d15 :  std_logic_vector(62 downto 0);
signal negateAB_d1, negateAB_d2, negateAB_d3, negateAB_d4, negateAB_d5, negateAB_d6, negateAB_d7 :  std_logic;
signal negateC_d1, negateC_d2, negateC_d3, negateC_d4, negateC_d5, negateC_d6, negateC_d7 :  std_logic;
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            Asgn_d1 <=  Asgn;
            Asgn_d2 <=  Asgn_d1;
            Asgn_d3 <=  Asgn_d2;
            Asgn_d4 <=  Asgn_d3;
            Asgn_d5 <=  Asgn_d4;
            Asgn_d6 <=  Asgn_d5;
            Asgn_d7 <=  Asgn_d6;
            AisZero_d1 <=  AisZero;
            AisZero_d2 <=  AisZero_d1;
            AisZero_d3 <=  AisZero_d2;
            AisZero_d4 <=  AisZero_d3;
            AisZero_d5 <=  AisZero_d4;
            AisZero_d6 <=  AisZero_d5;
            AisZero_d7 <=  AisZero_d6;
            Bsgn_d1 <=  Bsgn;
            Bsgn_d2 <=  Bsgn_d1;
            Bsgn_d3 <=  Bsgn_d2;
            Bsgn_d4 <=  Bsgn_d3;
            Bsgn_d5 <=  Bsgn_d4;
            Bsgn_d6 <=  Bsgn_d5;
            Bsgn_d7 <=  Bsgn_d6;
            BisZero_d1 <=  BisZero;
            BisZero_d2 <=  BisZero_d1;
            BisZero_d3 <=  BisZero_d2;
            BisZero_d4 <=  BisZero_d3;
            BisZero_d5 <=  BisZero_d4;
            BisZero_d6 <=  BisZero_d5;
            BisZero_d7 <=  BisZero_d6;
            AexpPlusBexp_d1 <=  AexpPlusBexp;
            AexpPlusBexp_d2 <=  AexpPlusBexp_d1;
            AexpPlusBexp_d3 <=  AexpPlusBexp_d2;
            AexpPlusBexp_d4 <=  AexpPlusBexp_d3;
            AexpPlusBexp_d5 <=  AexpPlusBexp_d4;
            AexpPlusBexp_d6 <=  AexpPlusBexp_d5;
            AexpPlusBexp_d7 <=  AexpPlusBexp_d6;
            Csgn_d1 <=  Csgn;
            Csgn_d2 <=  Csgn_d1;
            Csgn_d3 <=  Csgn_d2;
            Csgn_d4 <=  Csgn_d3;
            Csgn_d5 <=  Csgn_d4;
            Csgn_d6 <=  Csgn_d5;
            Csgn_d7 <=  Csgn_d6;
            CisNormal_d1 <=  CisNormal;
            CisNormal_d2 <=  CisNormal_d1;
            CisNormal_d3 <=  CisNormal_d2;
            CisNormal_d4 <=  CisNormal_d3;
            CisNormal_d5 <=  CisNormal_d4;
            CisNormal_d6 <=  CisNormal_d5;
            CisNormal_d7 <=  CisNormal_d6;
            CisZero_d1 <=  CisZero;
            CisZero_d2 <=  CisZero_d1;
            CisZero_d3 <=  CisZero_d2;
            CisZero_d4 <=  CisZero_d3;
            CisZero_d5 <=  CisZero_d4;
            CisZero_d6 <=  CisZero_d5;
            CisZero_d7 <=  CisZero_d6;
            RisNaN_d1 <=  RisNaN;
            RisNaN_d2 <=  RisNaN_d1;
            RisNaN_d3 <=  RisNaN_d2;
            RisNaN_d4 <=  RisNaN_d3;
            RisNaN_d5 <=  RisNaN_d4;
            RisNaN_d6 <=  RisNaN_d5;
            RisNaN_d7 <=  RisNaN_d6;
            RisNaN_d8 <=  RisNaN_d7;
            RisNaN_d9 <=  RisNaN_d8;
            RisNaN_d10 <=  RisNaN_d9;
            RisNaN_d11 <=  RisNaN_d10;
            RisNaN_d12 <=  RisNaN_d11;
            RisNaN_d13 <=  RisNaN_d12;
            RisNaN_d14 <=  RisNaN_d13;
            RisNaN_d15 <=  RisNaN_d14;
            tentativeRisInf_d1 <=  tentativeRisInf;
            tentativeRisInf_d2 <=  tentativeRisInf_d1;
            tentativeRisInf_d3 <=  tentativeRisInf_d2;
            tentativeRisInf_d4 <=  tentativeRisInf_d3;
            tentativeRisInf_d5 <=  tentativeRisInf_d4;
            tentativeRisInf_d6 <=  tentativeRisInf_d5;
            tentativeRisInf_d7 <=  tentativeRisInf_d6;
            tentativeRisInf_d8 <=  tentativeRisInf_d7;
            tentativeRisInf_d9 <=  tentativeRisInf_d8;
            tentativeRisInf_d10 <=  tentativeRisInf_d9;
            tentativeRisInf_d11 <=  tentativeRisInf_d10;
            tentativeRisInf_d12 <=  tentativeRisInf_d11;
            tentativeRisInf_d13 <=  tentativeRisInf_d12;
            tentativeRisInf_d14 <=  tentativeRisInf_d13;
            tentativeRisInf_d15 <=  tentativeRisInf_d14;
            Cexp_d1 <=  Cexp;
            Cexp_d2 <=  Cexp_d1;
            Cexp_d3 <=  Cexp_d2;
            Cexp_d4 <=  Cexp_d3;
            Cexp_d5 <=  Cexp_d4;
            Cexp_d6 <=  Cexp_d5;
            Cexp_d7 <=  Cexp_d6;
            effectiveSub_d1 <=  effectiveSub;
            effectiveSub_d2 <=  effectiveSub_d1;
            effectiveSub_d3 <=  effectiveSub_d2;
            effectiveSub_d4 <=  effectiveSub_d3;
            expDiffSmall_d1 <=  expDiffSmall;
            expDiffSmall_d2 <=  expDiffSmall_d1;
            expDiffSmall_d3 <=  expDiffSmall_d2;
            expDiffSmall_d4 <=  expDiffSmall_d3;
            expDiffSmall_d5 <=  expDiffSmall_d4;
            expDiffSmall_d6 <=  expDiffSmall_d5;
            expDiffSmall_d7 <=  expDiffSmall_d6;
            ShiftValue_d1 <=  ShiftValue;
            ShiftValue_d2 <=  ShiftValue_d1;
            ShiftValue_d3 <=  ShiftValue_d2;
            ShiftValue_d4 <=  ShiftValue_d3;
            ShiftValue_d5 <=  ShiftValue_d4;
            ShiftValue_d6 <=  ShiftValue_d5;
            ShiftValue_d7 <=  ShiftValue_d6;
            sticky1_d1 <=  sticky1;
            sticky1_d2 <=  sticky1_d1;
            sticky1_d3 <=  sticky1_d2;
            sticky1_d4 <=  sticky1_d3;
            sticky1_d5 <=  sticky1_d4;
            sticky1_d6 <=  sticky1_d5;
            sticky1_d7 <=  sticky1_d6;
            sticky1_d8 <=  sticky1_d7;
            sticky1_d9 <=  sticky1_d8;
            sticky1_d10 <=  sticky1_d9;
            sticky1_d11 <=  sticky1_d10;
            Paligned_d1 <=  Paligned;
            Paligned_d2 <=  Paligned_d1;
            Paligned_d3 <=  Paligned_d2;
            Paligned_d4 <=  Paligned_d3;
            RsgnTentative_d1 <=  RsgnTentative;
            RsgnTentative_d2 <=  RsgnTentative_d1;
            RsgnTentative_d3 <=  RsgnTentative_d2;
            tmpExpCompRes1_d1 <=  tmpExpCompRes1;
            tmpExpCompRes1_d2 <=  tmpExpCompRes1_d1;
            tmpExpCompRes1_d3 <=  tmpExpCompRes1_d2;
            tmpExpCompRes1_d4 <=  tmpExpCompRes1_d3;
            tmpExpCompRes1_d5 <=  tmpExpCompRes1_d4;
            tmpExpCompRes1_d6 <=  tmpExpCompRes1_d5;
            tmpExpCompRes1_d7 <=  tmpExpCompRes1_d6;
            RisSubNormal_d1 <=  RisSubNormal;
            RisSubNormal_d2 <=  RisSubNormal_d1;
            RisSubNormal_d3 <=  RisSubNormal_d2;
            RisSubNormal_d4 <=  RisSubNormal_d3;
            RisSubNormal_d5 <=  RisSubNormal_d4;
            RisSubNormal_d6 <=  RisSubNormal_d5;
            RisSubNormal_d7 <=  RisSubNormal_d6;
            RisSubNormal_d8 <=  RisSubNormal_d7;
            RisZero_d1 <=  RisZero;
            RisZero_d2 <=  RisZero_d1;
            RisZero_d3 <=  RisZero_d2;
            RisZero_d4 <=  RisZero_d3;
            RisZero_d5 <=  RisZero_d4;
            RisZero_d6 <=  RisZero_d5;
            RisZero_d7 <=  RisZero_d6;
            RisZero_d8 <=  RisZero_d7;
            Rsgn_d1 <=  Rsgn;
            Rsgn_d2 <=  Rsgn_d1;
            Rsgn_d3 <=  Rsgn_d2;
            Rsgn_d4 <=  Rsgn_d3;
            Rsgn_d5 <=  Rsgn_d4;
            Rsgn_d6 <=  Rsgn_d5;
            Rsgn_d7 <=  Rsgn_d6;
            Rsgn_d8 <=  Rsgn_d7;
            shiftValueCaseSubnormal_d1 <=  shiftValueCaseSubnormal;
            shiftValueCaseSubnormal_d2 <=  shiftValueCaseSubnormal_d1;
            shiftValueCaseSubnormal_d3 <=  shiftValueCaseSubnormal_d2;
            shiftValueCaseSubnormal_d4 <=  shiftValueCaseSubnormal_d3;
            shiftValueCaseSubnormal_d5 <=  shiftValueCaseSubnormal_d4;
            shiftValueCaseSubnormal_d6 <=  shiftValueCaseSubnormal_d5;
            shiftValueCaseSubnormal_d7 <=  shiftValueCaseSubnormal_d6;
            expTentative_d1 <=  expTentative;
            expTentative_d2 <=  expTentative_d1;
            expTentative_d3 <=  expTentative_d2;
            expTentative_d4 <=  expTentative_d3;
            expTentative_d5 <=  expTentative_d4;
            expTentative_d6 <=  expTentative_d5;
            expTentative_d7 <=  expTentative_d6;
            expTentative_d8 <=  expTentative_d7;
            Inf_d1 <=  Inf;
            Inf_d2 <=  Inf_d1;
            Inf_d3 <=  Inf_d2;
            Inf_d4 <=  Inf_d3;
            Inf_d5 <=  Inf_d4;
            Inf_d6 <=  Inf_d5;
            Inf_d7 <=  Inf_d6;
            Inf_d8 <=  Inf_d7;
            Inf_d9 <=  Inf_d8;
            Inf_d10 <=  Inf_d9;
            Inf_d11 <=  Inf_d10;
            Inf_d12 <=  Inf_d11;
            Inf_d13 <=  Inf_d12;
            Inf_d14 <=  Inf_d13;
            Inf_d15 <=  Inf_d14;
            NaN_d1 <=  NaN;
            NaN_d2 <=  NaN_d1;
            NaN_d3 <=  NaN_d2;
            NaN_d4 <=  NaN_d3;
            NaN_d5 <=  NaN_d4;
            NaN_d6 <=  NaN_d5;
            NaN_d7 <=  NaN_d6;
            NaN_d8 <=  NaN_d7;
            NaN_d9 <=  NaN_d8;
            NaN_d10 <=  NaN_d9;
            NaN_d11 <=  NaN_d10;
            NaN_d12 <=  NaN_d11;
            NaN_d13 <=  NaN_d12;
            NaN_d14 <=  NaN_d13;
            NaN_d15 <=  NaN_d14;
            negateAB_d1 <=  negateAB;
            negateAB_d2 <=  negateAB_d1;
            negateAB_d3 <=  negateAB_d2;
            negateAB_d4 <=  negateAB_d3;
            negateAB_d5 <=  negateAB_d4;
            negateAB_d6 <=  negateAB_d5;
            negateAB_d7 <=  negateAB_d6;
            negateC_d1 <=  negateC;
            negateC_d2 <=  negateC_d1;
            negateC_d3 <=  negateC_d2;
            negateC_d4 <=  negateC_d3;
            negateC_d5 <=  negateC_d4;
            negateC_d6 <=  negateC_d5;
            negateC_d7 <=  negateC_d6;
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
   RightShifterComponent: RightShifter53_by_max_163_F400_uid4
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
   CsigInverted <= ('0' &CsigShiftedT) when effectiveSub_d4='0'  else ('1' & not CsigShiftedT);
   BigSum <= CsigInverted + ('0' & Paligned_d4) + effectiveSub_d4;  -- P +/-CeffectiveSub is a carry in
   BigSum2 <= CsigShiftedT - ('0' & Paligned_d4);
   RsgnTentative <= Asgn_d4 xor Bsgn_d4 xor negateAB_d4 xor BigSum(163);
   BigSumAbs <= BigSum(162 downto 0) when (BigSum2(163) or not effectiveSub_d4)='1' else BigSum2(162 downto 0);
   BigSumAbsLowerBits <= BigSumAbs(109 downto 0);
   IEEEFMA_11_52_F400_uid2LeadingZeroCounter: LZC_110_F400_uid6
      port map ( clk  => clk,
                 I => BigSumAbsLowerBits,
                 O => L);
   tmpExpCompRes1 <= (AexpPlusBexp(11) & AexpPlusBexp) + "0010000000001";
   tmpExpCompRes2 <= tmpExpCompRes1_d7 - ((12 downto 7 => '0') & L);
   RisSubNormal <= (expDiffSmall_d7 or not CisNormal_d7) and  tmpExpCompRes2(12);
   RisZero <= expDiffSmall_d7 when L="1101110"  else '0';
   RisSubNormalOrZero <= RisSubNormal or RisZero;
   Rsgn <=      (Asgn_d7 xor Bsgn_d7 xor negateAB_d7) and (Csgn_d7 xor negateC_d7) when ((AisZero_d7 or BisZero_d7) and CisZero_d7)='1'  -- negative only for -0 + -0 
      else '0' when RisZero='1'  -- covers 1-1 = +0
      else RsgnTentative_d3;  -- covers to underflow to zero case
   shiftValueCaseSubnormal <= AexpPlusBexp + "010000110110";
   normShiftValue <= 
           L + "00110110" when (expDiffSmall_d7 and not RisSubNormal)='1'
      else shiftValueCaseSubnormal_d7(7 downto 0) when (expDiffSmall_d7 and RisSubNormal)='1'
      else ShiftValue_d7; -- undo inital shift
   NormalizationShifter: LeftShifter163_by_max_162_F400_uid8
      port map ( clk  => clk,
                 S => normShiftValue,
                 X => BigSumAbs,
                 R => BigSumNormd);
   -- TODO opt: push all the constant additions to exponentUpdate
   expTentative <= 
           "1110000000011" when RisZero='1'
      else "1110000000010" when RisSubNormal='1'
      else (AexpPlusBexp_d7(11) & AexpPlusBexp_d7 - ((12 downto 7 => '0') & L))  + "0000000000011" when (expDiffSmall_d7 and not RisSubNormal)='1'
      else (Cexp_d7(10) & Cexp_d7(10) & Cexp_d7) + "0000000000001" ;
   sticky2 <= BigSumNormd(0) or BigSumNormd(1) or BigSumNormd(2) or BigSumNormd(3) or BigSumNormd(4) or BigSumNormd(5) or BigSumNormd(6) or BigSumNormd(7) or BigSumNormd(8) or BigSumNormd(9) or BigSumNormd(10) or BigSumNormd(11) or BigSumNormd(12) or BigSumNormd(13) or BigSumNormd(14) or BigSumNormd(15) or BigSumNormd(16) or BigSumNormd(17) or BigSumNormd(18) or BigSumNormd(19) or BigSumNormd(20) or BigSumNormd(21) or BigSumNormd(22) or BigSumNormd(23) or BigSumNormd(24) or BigSumNormd(25) or BigSumNormd(26) or BigSumNormd(27) or BigSumNormd(28) or BigSumNormd(29) or BigSumNormd(30) or BigSumNormd(31) or BigSumNormd(32) or BigSumNormd(33) or BigSumNormd(34) or BigSumNormd(35) or BigSumNormd(36) or BigSumNormd(37) or BigSumNormd(38) or BigSumNormd(39) or BigSumNormd(40) or BigSumNormd(41) or BigSumNormd(42) or BigSumNormd(43) or BigSumNormd(44) or BigSumNormd(45) or BigSumNormd(46) or BigSumNormd(47) or BigSumNormd(48) or BigSumNormd(49) or BigSumNormd(50) or BigSumNormd(51) or BigSumNormd(52) or BigSumNormd(53) or BigSumNormd(54) or BigSumNormd(55) or BigSumNormd(56) or BigSumNormd(57) or BigSumNormd(58) or BigSumNormd(59) or BigSumNormd(60) or BigSumNormd(61) or BigSumNormd(62) or BigSumNormd(63) or BigSumNormd(64) or BigSumNormd(65) or BigSumNormd(66) or BigSumNormd(67) or BigSumNormd(68) or BigSumNormd(69) or BigSumNormd(70) or BigSumNormd(71) or BigSumNormd(72) or BigSumNormd(73) or BigSumNormd(74) or BigSumNormd(75) or BigSumNormd(76) or BigSumNormd(77) or BigSumNormd(78) or BigSumNormd(79) or BigSumNormd(80) or BigSumNormd(81) or BigSumNormd(82) or BigSumNormd(83) or BigSumNormd(84) or BigSumNormd(85) or BigSumNormd(86) or BigSumNormd(87) or BigSumNormd(88) or BigSumNormd(89) or BigSumNormd(90) or BigSumNormd(91) or BigSumNormd(92) or BigSumNormd(93) or BigSumNormd(94) or BigSumNormd(95) or BigSumNormd(96) or BigSumNormd(97) or BigSumNormd(98) or BigSumNormd(99) or BigSumNormd(100) or BigSumNormd(101) or BigSumNormd(102) or BigSumNormd(103) or BigSumNormd(104) or BigSumNormd(105) or BigSumNormd(106) or BigSumNormd(107);

   fracTentative <= BigSumNormd(163 downto 108);

    -- Last 2-bit normalization 
   fracLeadingBitsNormal <=  fracTentative(55 downto 54) ;
   fracLeadingBits <= "01" when RisSubNormal_d8='1' else  fracLeadingBitsNormal;
   fracResultNormd <=
           fracTentative(52 downto 1)  when fracLeadingBits = "00" 
      else fracTentative(53 downto 2)  when fracLeadingBits = "01" 
      else fracTentative(54 downto 3);
   fracResultRoundBit <=
           fracTentative(0) 	 when fracLeadingBits = "00" 
      else fracTentative(1)    when fracLeadingBits = "01" 
      else fracTentative(2) ;
   fracResultStickyBit <=
           sticky1_d11 or sticky2	 when fracLeadingBits = "00" 
      else fracTentative(0) or sticky1_d11 or sticky2    when fracLeadingBits = "01" 
      else fracTentative(1) or fracTentative(0) or  sticky1_d11 or sticky2;
   round <= fracResultRoundBit and (fracResultStickyBit or fracResultNormd(0));
   expUpdate <= "0001111111101" when RisZero_d8 = '1'       -- bias - 2
         else   "0001111111101" when fracLeadingBits = "00" -- bias - 2
         else   "0001111111110" when fracLeadingBits = "01" -- bias - 1 
         else   "0001111111111";                            -- bias 
   exponentResult1 <= expTentative_d8 + expUpdate;
   resultBeforeRound <= exponentResult1 & fracResultNormd;
   resultRounded <= resultBeforeRound + ((64 downto 1 => '0') & round);
   Roverflowed <= resultRounded(64) or resultRounded(63) or (resultRounded(62) and resultRounded(61) and resultRounded(60) and resultRounded(59) and resultRounded(58) and resultRounded(57) and resultRounded(56) and resultRounded(55) and resultRounded(54) and resultRounded(53) and resultRounded(52));
   finalRisInf <= tentativeRisInf_d15 or Roverflowed; 
   Inf <= (62 downto 52 => '1') & (51 downto 0 => '0');
   NaN <= (62 downto 52 => '1') & (51 downto 0 => '1');
   R <= 
           Rsgn_d8 & Inf_d15 when ((not RisNaN_d15) and finalRisInf)='1'
      else '0'  & NaN_d15 when RisNaN_d15='1'
      else Rsgn_d8 & resultRounded(62 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                    RightShifter24_by_max_76_F400_uid12
-- VHDL generated for Kintex7 @ 400MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2008-2011), Florent de Dinechin (2008-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 1 cycles
-- Clock period (ns): 2.5
-- Target frequency (MHz): 400
-- Input signals: X S
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity RightShifter24_by_max_76_F400_uid12 is
    port (clk : in std_logic;
          X : in  std_logic_vector(23 downto 0);
          S : in  std_logic_vector(6 downto 0);
          R : out  std_logic_vector(99 downto 0)   );
end entity;

architecture arch of RightShifter24_by_max_76_F400_uid12 is
signal ps, ps_d1 :  std_logic_vector(6 downto 0);
signal level0 :  std_logic_vector(23 downto 0);
signal level1 :  std_logic_vector(24 downto 0);
signal level2 :  std_logic_vector(26 downto 0);
signal level3 :  std_logic_vector(30 downto 0);
signal level4 :  std_logic_vector(38 downto 0);
signal level5, level5_d1 :  std_logic_vector(54 downto 0);
signal level6 :  std_logic_vector(86 downto 0);
signal level7 :  std_logic_vector(150 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            ps_d1 <=  ps;
            level5_d1 <=  level5;
         end if;
      end process;
   ps<= S;
   level0<= X;
   level1 <=  (0 downto 0 => '0') & level0 when ps(0) = '1' else    level0 & (0 downto 0 => '0');
   R <= level7(150 downto 51);
   level2 <=  (1 downto 0 => '0') & level1 when ps(1) = '1' else    level1 & (1 downto 0 => '0');
   R <= level7(150 downto 51);
   level3 <=  (3 downto 0 => '0') & level2 when ps(2) = '1' else    level2 & (3 downto 0 => '0');
   R <= level7(150 downto 51);
   level4 <=  (7 downto 0 => '0') & level3 when ps(3) = '1' else    level3 & (7 downto 0 => '0');
   R <= level7(150 downto 51);
   level5 <=  (15 downto 0 => '0') & level4 when ps(4) = '1' else    level4 & (15 downto 0 => '0');
   R <= level7(150 downto 51);
   level6 <=  (31 downto 0 => '0') & level5_d1 when ps_d1(5) = '1' else    level5_d1 & (31 downto 0 => '0');
   R <= level7(150 downto 51);
   level7 <=  (63 downto 0 => '0') & level6 when ps_d1(6) = '1' else    level6 & (63 downto 0 => '0');
   R <= level7(150 downto 51);
end architecture;

--------------------------------------------------------------------------------
--                             LZC_52_F400_uid14
-- VHDL generated for Kintex7 @ 400MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, Bogdan Pasca (2007)
--------------------------------------------------------------------------------
-- Pipeline depth: 2 cycles
-- Clock period (ns): 2.5
-- Target frequency (MHz): 400
-- Input signals: I
-- Output signals: O

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity LZC_52_F400_uid14 is
    port (clk : in std_logic;
          I : in  std_logic_vector(51 downto 0);
          O : out  std_logic_vector(5 downto 0)   );
end entity;

architecture arch of LZC_52_F400_uid14 is
signal level6, level6_d1 :  std_logic_vector(62 downto 0);
signal digit5, digit5_d1 :  std_logic;
signal level5 :  std_logic_vector(30 downto 0);
signal digit4, digit4_d1 :  std_logic;
signal level4, level4_d1 :  std_logic_vector(14 downto 0);
signal digit3 :  std_logic;
signal level3 :  std_logic_vector(6 downto 0);
signal digit2 :  std_logic;
signal level2 :  std_logic_vector(2 downto 0);
signal lowBits :  std_logic_vector(1 downto 0);
signal outHighBits :  std_logic_vector(3 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            level6_d1 <=  level6;
            digit5_d1 <=  digit5;
            digit4_d1 <=  digit4;
            level4_d1 <=  level4;
         end if;
      end process;
   -- pad input to the next power of two minus 1
   level6 <= I & "11111111111";
   -- Main iteration for large inputs
   digit5<= '1' when level6_d1(62 downto 31) = "00000000000000000000000000000000" else '0';
   level5<= level6_d1(30 downto 0) when digit5='1' else level6_d1(62 downto 32);
   digit4<= '1' when level5(30 downto 15) = "0000000000000000" else '0';
   level4<= level5(14 downto 0) when digit4='1' else level5(30 downto 16);
   digit3<= '1' when level4_d1(14 downto 7) = "00000000" else '0';
   level3<= level4_d1(6 downto 0) when digit3='1' else level4_d1(14 downto 8);
   digit2<= '1' when level3(6 downto 3) = "0000" else '0';
   level2<= level3(2 downto 0) when digit2='1' else level3(6 downto 4);
   -- Finish counting with one LUT
   with level2  select  lowBits <= 
      "11" when "000",
      "10" when "001",
      "01" when "010",
      "01" when "011",
      "00" when others;
   outHighBits <= digit5_d1 & digit4_d1 & digit3 & digit2 & "";
   O <= outHighBits & lowBits ;
end architecture;

--------------------------------------------------------------------------------
--                     LeftShifter76_by_max_75_F400_uid16
-- VHDL generated for Kintex7 @ 400MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2008-2011), Florent de Dinechin (2008-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 3 cycles
-- Clock period (ns): 2.5
-- Target frequency (MHz): 400
-- Input signals: X S
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity LeftShifter76_by_max_75_F400_uid16 is
    port (clk : in std_logic;
          X : in  std_logic_vector(75 downto 0);
          S : in  std_logic_vector(6 downto 0);
          R : out  std_logic_vector(150 downto 0)   );
end entity;

architecture arch of LeftShifter76_by_max_75_F400_uid16 is
signal ps, ps_d1, ps_d2, ps_d3 :  std_logic_vector(6 downto 0);
signal level0, level0_d1, level0_d2 :  std_logic_vector(75 downto 0);
signal level1, level1_d1 :  std_logic_vector(76 downto 0);
signal level2 :  std_logic_vector(78 downto 0);
signal level3, level3_d1 :  std_logic_vector(82 downto 0);
signal level4 :  std_logic_vector(90 downto 0);
signal level5, level5_d1 :  std_logic_vector(106 downto 0);
signal level6 :  std_logic_vector(138 downto 0);
signal level7 :  std_logic_vector(202 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            ps_d1 <=  ps;
            ps_d2 <=  ps_d1;
            ps_d3 <=  ps_d2;
            level0_d1 <=  level0;
            level0_d2 <=  level0_d1;
            level1_d1 <=  level1;
            level3_d1 <=  level3;
            level5_d1 <=  level5;
         end if;
      end process;
   ps<= S;
   level0<= X;
   level1<= level0_d2 & (0 downto 0 => '0') when ps(0)= '1' else     (0 downto 0 => '0') & level0_d2;
   R <= level7(150 downto 0);
   level2<= level1_d1 & (1 downto 0 => '0') when ps_d1(1)= '1' else     (1 downto 0 => '0') & level1_d1;
   R <= level7(150 downto 0);
   level3<= level2 & (3 downto 0 => '0') when ps_d1(2)= '1' else     (3 downto 0 => '0') & level2;
   R <= level7(150 downto 0);
   level4<= level3_d1 & (7 downto 0 => '0') when ps_d2(3)= '1' else     (7 downto 0 => '0') & level3_d1;
   R <= level7(150 downto 0);
   level5<= level4 & (15 downto 0 => '0') when ps_d2(4)= '1' else     (15 downto 0 => '0') & level4;
   R <= level7(150 downto 0);
   level6<= level5_d1 & (31 downto 0 => '0') when ps_d3(5)= '1' else     (31 downto 0 => '0') & level5_d1;
   R <= level7(150 downto 0);
   level7<= level6 & (63 downto 0 => '0') when ps_d3(6)= '1' else     (63 downto 0 => '0') & level6;
   R <= level7(150 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                                   FMA_S
--                         (IEEEFMA_8_23_F400_uid10)
-- Inputs: this FMA computes A*B+C
-- VHDL generated for Kintex7 @ 400MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin (2009-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 6 cycles
-- Clock period (ns): 2.5
-- Target frequency (MHz): 400
-- Input signals: A B C negateAB negateC RndMode
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FMA_S is
    port (clk : in std_logic;
          A : in  std_logic_vector(31 downto 0);
          B : in  std_logic_vector(31 downto 0);
          C : in  std_logic_vector(31 downto 0);
          negateAB : in  std_logic;
          negateC : in  std_logic;
          RndMode : in  std_logic_vector(1 downto 0);
          R : out  std_logic_vector(31 downto 0)   );
end entity;

architecture arch of FMA_S is
   component RightShifter24_by_max_76_F400_uid12 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(23 downto 0);
             S : in  std_logic_vector(6 downto 0);
             R : out  std_logic_vector(99 downto 0)   );
   end component;

   component LZC_52_F400_uid14 is
      port ( clk : in std_logic;
             I : in  std_logic_vector(51 downto 0);
             O : out  std_logic_vector(5 downto 0)   );
   end component;

   component LeftShifter76_by_max_75_F400_uid16 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(75 downto 0);
             S : in  std_logic_vector(6 downto 0);
             R : out  std_logic_vector(150 downto 0)   );
   end component;

signal Asgn, Asgn_d1, Asgn_d2, Asgn_d3 :  std_logic;
signal AexpField :  std_logic_vector(7 downto 0);
signal AsigField :  std_logic_vector(22 downto 0);
signal AisNormal :  std_logic;
signal AisInfOrNaN :  std_logic;
signal AhasNonNullSig :  std_logic;
signal AisZero, AisZero_d1, AisZero_d2, AisZero_d3 :  std_logic;
signal AisInf :  std_logic;
signal AisNaN :  std_logic;
signal Bsgn, Bsgn_d1, Bsgn_d2, Bsgn_d3 :  std_logic;
signal BexpField :  std_logic_vector(7 downto 0);
signal BsigField :  std_logic_vector(22 downto 0);
signal BisNormal :  std_logic;
signal BisInfOrNaN :  std_logic;
signal BhasNonNullSig :  std_logic;
signal BisZero, BisZero_d1, BisZero_d2, BisZero_d3 :  std_logic;
signal BisInf :  std_logic;
signal BisNaN :  std_logic;
signal Aexp :  std_logic_vector(7 downto 0);
signal Bexp :  std_logic_vector(7 downto 0);
signal Asig :  std_logic_vector(23 downto 0);
signal Bsig :  std_logic_vector(23 downto 0);
signal AexpPlusBexp, AexpPlusBexp_d1, AexpPlusBexp_d2, AexpPlusBexp_d3 :  std_logic_vector(8 downto 0);
signal Csgn, Csgn_d1, Csgn_d2, Csgn_d3 :  std_logic;
signal CexpField :  std_logic_vector(7 downto 0);
signal CsigField :  std_logic_vector(22 downto 0);
signal CisNormal, CisNormal_d1, CisNormal_d2, CisNormal_d3 :  std_logic;
signal CisInfOrNaN :  std_logic;
signal ChasNonNullSig :  std_logic;
signal CisZero, CisZero_d1, CisZero_d2, CisZero_d3 :  std_logic;
signal CisInf :  std_logic;
signal CisNaN :  std_logic;
signal RisNaN, RisNaN_d1, RisNaN_d2, RisNaN_d3, RisNaN_d4, RisNaN_d5, RisNaN_d6 :  std_logic;
signal tentativeRisInf, tentativeRisInf_d1, tentativeRisInf_d2, tentativeRisInf_d3, tentativeRisInf_d4, tentativeRisInf_d5, tentativeRisInf_d6 :  std_logic;
signal Cexp, Cexp_d1, Cexp_d2, Cexp_d3 :  std_logic_vector(7 downto 0);
signal effectiveSub, effectiveSub_d1 :  std_logic;
signal Csig :  std_logic_vector(23 downto 0);
signal expDiffPrepare :  std_logic_vector(9 downto 0);
signal expDiff :  std_logic_vector(9 downto 0);
signal tmpExpComp1 :  std_logic_vector(9 downto 0);
signal expDiffVerySmall :  std_logic;
signal tmpExpComp2 :  std_logic_vector(9 downto 0);
signal expDiffSmall, expDiffSmall_d1, expDiffSmall_d2, expDiffSmall_d3 :  std_logic;
signal tmpExpComp3 :  std_logic_vector(9 downto 0);
signal expDiffNotLarge :  std_logic;
signal ShiftValue, ShiftValue_d1, ShiftValue_d2, ShiftValue_d3 :  std_logic_vector(6 downto 0);
signal CsigShifted :  std_logic_vector(99 downto 0);
signal sticky1, sticky1_d1, sticky1_d2, sticky1_d3, sticky1_d4, sticky1_d5 :  std_logic;
signal CsigShiftedT :  std_logic_vector(75 downto 0);
signal P :  std_logic_vector(47 downto 0);
signal Paligned, Paligned_d1 :  std_logic_vector(75 downto 0);
signal CsigInverted :  std_logic_vector(76 downto 0);
signal BigSum :  std_logic_vector(76 downto 0);
signal BigSum2 :  std_logic_vector(76 downto 0);
signal RsgnTentative, RsgnTentative_d1, RsgnTentative_d2 :  std_logic;
signal BigSumAbs :  std_logic_vector(75 downto 0);
signal BigSumAbsLowerBits :  std_logic_vector(51 downto 0);
signal L :  std_logic_vector(5 downto 0);
signal tmpExpCompRes1, tmpExpCompRes1_d1, tmpExpCompRes1_d2, tmpExpCompRes1_d3 :  std_logic_vector(9 downto 0);
signal tmpExpCompRes2 :  std_logic_vector(9 downto 0);
signal RisSubNormal, RisSubNormal_d1, RisSubNormal_d2, RisSubNormal_d3 :  std_logic;
signal RisZero, RisZero_d1, RisZero_d2, RisZero_d3 :  std_logic;
signal RisSubNormalOrZero :  std_logic;
signal Rsgn, Rsgn_d1, Rsgn_d2, Rsgn_d3 :  std_logic;
signal shiftValueCaseSubnormal, shiftValueCaseSubnormal_d1, shiftValueCaseSubnormal_d2, shiftValueCaseSubnormal_d3 :  std_logic_vector(8 downto 0);
signal normShiftValue :  std_logic_vector(6 downto 0);
signal BigSumNormd :  std_logic_vector(150 downto 0);
signal expTentative, expTentative_d1, expTentative_d2, expTentative_d3 :  std_logic_vector(9 downto 0);
signal sticky2 :  std_logic;
signal fracTentative :  std_logic_vector(26 downto 0);
signal fracLeadingBitsNormal :  std_logic_vector(1 downto 0);
signal fracLeadingBits :  std_logic_vector(1 downto 0);
signal fracResultNormd :  std_logic_vector(22 downto 0);
signal fracResultRoundBit :  std_logic;
signal fracResultStickyBit :  std_logic;
signal round :  std_logic;
signal expUpdate :  std_logic_vector(9 downto 0);
signal exponentResult1 :  std_logic_vector(9 downto 0);
signal resultBeforeRound :  std_logic_vector(32 downto 0);
signal resultRounded :  std_logic_vector(32 downto 0);
signal Roverflowed :  std_logic;
signal finalRisInf :  std_logic;
signal Inf, Inf_d1, Inf_d2, Inf_d3, Inf_d4, Inf_d5, Inf_d6 :  std_logic_vector(30 downto 0);
signal NaN, NaN_d1, NaN_d2, NaN_d3, NaN_d4, NaN_d5, NaN_d6 :  std_logic_vector(30 downto 0);
signal negateAB_d1, negateAB_d2, negateAB_d3 :  std_logic;
signal negateC_d1, negateC_d2, negateC_d3 :  std_logic;
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            Asgn_d1 <=  Asgn;
            Asgn_d2 <=  Asgn_d1;
            Asgn_d3 <=  Asgn_d2;
            AisZero_d1 <=  AisZero;
            AisZero_d2 <=  AisZero_d1;
            AisZero_d3 <=  AisZero_d2;
            Bsgn_d1 <=  Bsgn;
            Bsgn_d2 <=  Bsgn_d1;
            Bsgn_d3 <=  Bsgn_d2;
            BisZero_d1 <=  BisZero;
            BisZero_d2 <=  BisZero_d1;
            BisZero_d3 <=  BisZero_d2;
            AexpPlusBexp_d1 <=  AexpPlusBexp;
            AexpPlusBexp_d2 <=  AexpPlusBexp_d1;
            AexpPlusBexp_d3 <=  AexpPlusBexp_d2;
            Csgn_d1 <=  Csgn;
            Csgn_d2 <=  Csgn_d1;
            Csgn_d3 <=  Csgn_d2;
            CisNormal_d1 <=  CisNormal;
            CisNormal_d2 <=  CisNormal_d1;
            CisNormal_d3 <=  CisNormal_d2;
            CisZero_d1 <=  CisZero;
            CisZero_d2 <=  CisZero_d1;
            CisZero_d3 <=  CisZero_d2;
            RisNaN_d1 <=  RisNaN;
            RisNaN_d2 <=  RisNaN_d1;
            RisNaN_d3 <=  RisNaN_d2;
            RisNaN_d4 <=  RisNaN_d3;
            RisNaN_d5 <=  RisNaN_d4;
            RisNaN_d6 <=  RisNaN_d5;
            tentativeRisInf_d1 <=  tentativeRisInf;
            tentativeRisInf_d2 <=  tentativeRisInf_d1;
            tentativeRisInf_d3 <=  tentativeRisInf_d2;
            tentativeRisInf_d4 <=  tentativeRisInf_d3;
            tentativeRisInf_d5 <=  tentativeRisInf_d4;
            tentativeRisInf_d6 <=  tentativeRisInf_d5;
            Cexp_d1 <=  Cexp;
            Cexp_d2 <=  Cexp_d1;
            Cexp_d3 <=  Cexp_d2;
            effectiveSub_d1 <=  effectiveSub;
            expDiffSmall_d1 <=  expDiffSmall;
            expDiffSmall_d2 <=  expDiffSmall_d1;
            expDiffSmall_d3 <=  expDiffSmall_d2;
            ShiftValue_d1 <=  ShiftValue;
            ShiftValue_d2 <=  ShiftValue_d1;
            ShiftValue_d3 <=  ShiftValue_d2;
            sticky1_d1 <=  sticky1;
            sticky1_d2 <=  sticky1_d1;
            sticky1_d3 <=  sticky1_d2;
            sticky1_d4 <=  sticky1_d3;
            sticky1_d5 <=  sticky1_d4;
            Paligned_d1 <=  Paligned;
            RsgnTentative_d1 <=  RsgnTentative;
            RsgnTentative_d2 <=  RsgnTentative_d1;
            tmpExpCompRes1_d1 <=  tmpExpCompRes1;
            tmpExpCompRes1_d2 <=  tmpExpCompRes1_d1;
            tmpExpCompRes1_d3 <=  tmpExpCompRes1_d2;
            RisSubNormal_d1 <=  RisSubNormal;
            RisSubNormal_d2 <=  RisSubNormal_d1;
            RisSubNormal_d3 <=  RisSubNormal_d2;
            RisZero_d1 <=  RisZero;
            RisZero_d2 <=  RisZero_d1;
            RisZero_d3 <=  RisZero_d2;
            Rsgn_d1 <=  Rsgn;
            Rsgn_d2 <=  Rsgn_d1;
            Rsgn_d3 <=  Rsgn_d2;
            shiftValueCaseSubnormal_d1 <=  shiftValueCaseSubnormal;
            shiftValueCaseSubnormal_d2 <=  shiftValueCaseSubnormal_d1;
            shiftValueCaseSubnormal_d3 <=  shiftValueCaseSubnormal_d2;
            expTentative_d1 <=  expTentative;
            expTentative_d2 <=  expTentative_d1;
            expTentative_d3 <=  expTentative_d2;
            Inf_d1 <=  Inf;
            Inf_d2 <=  Inf_d1;
            Inf_d3 <=  Inf_d2;
            Inf_d4 <=  Inf_d3;
            Inf_d5 <=  Inf_d4;
            Inf_d6 <=  Inf_d5;
            NaN_d1 <=  NaN;
            NaN_d2 <=  NaN_d1;
            NaN_d3 <=  NaN_d2;
            NaN_d4 <=  NaN_d3;
            NaN_d5 <=  NaN_d4;
            NaN_d6 <=  NaN_d5;
            negateAB_d1 <=  negateAB;
            negateAB_d2 <=  negateAB_d1;
            negateAB_d3 <=  negateAB_d2;
            negateC_d1 <=  negateC;
            negateC_d2 <=  negateC_d1;
            negateC_d3 <=  negateC_d2;
         end if;
      end process;

    -- Input decomposition 
   Asgn <= A(31);
   AexpField <= A(30 downto 23);
   AsigField <= A(22 downto 0);
   AisNormal <= A(23) or A(24) or A(25) or A(26) or A(27) or A(28) or A(29) or A(30);
   AisInfOrNaN <= A(23) and A(24) and A(25) and A(26) and A(27) and A(28) and A(29) and A(30);
   AhasNonNullSig <= A(0) or A(1) or A(2) or A(3) or A(4) or A(5) or A(6) or A(7) or A(8) or A(9) or A(10) or A(11) or A(12) or A(13) or A(14) or A(15) or A(16) or A(17) or A(18) or A(19) or A(20) or A(21) or A(22);
   AisZero <= (not AisNormal) and not AhasNonNullSig;
   AisInf <= AisInfOrNaN and not AhasNonNullSig;
   AisNaN <= AisInfOrNaN and AhasNonNullSig;
   Bsgn <= B(31);
   BexpField <= B(30 downto 23);
   BsigField <= B(22 downto 0);
   BisNormal <= B(23) or B(24) or B(25) or B(26) or B(27) or B(28) or B(29) or B(30);
   BisInfOrNaN <= B(23) and B(24) and B(25) and B(26) and B(27) and B(28) and B(29) and B(30);
   BhasNonNullSig <= B(0) or B(1) or B(2) or B(3) or B(4) or B(5) or B(6) or B(7) or B(8) or B(9) or B(10) or B(11) or B(12) or B(13) or B(14) or B(15) or B(16) or B(17) or B(18) or B(19) or B(20) or B(21) or B(22);
   BisZero <= (not BisNormal) and not BhasNonNullSig;
   BisInf <= BisInfOrNaN and not BhasNonNullSig;
   BisNaN <= BisInfOrNaN and BhasNonNullSig;

   -- unbiased exponents make everything simpler but may lead to suboptimal arch 
   Aexp <= AexpField - ("0" & (6 downto 1 => '1') & AisNormal);
   Bexp <= BexpField - ("0" & (6 downto 1 => '1') & BisNormal);

   -- mantissa with the implicit 1 or 0 appended 
   Asig <= AisNormal & AsigField ;
   Bsig <= BisNormal & BsigField ;
   AexpPlusBexp <= (Aexp(7) & Aexp) + (Bexp(7) & Bexp) ;
   Csgn <= C(31);
   CexpField <= C(30 downto 23);
   CsigField <= C(22 downto 0);
   CisNormal <= C(23) or C(24) or C(25) or C(26) or C(27) or C(28) or C(29) or C(30);
   CisInfOrNaN <= C(23) and C(24) and C(25) and C(26) and C(27) and C(28) and C(29) and C(30);
   ChasNonNullSig <= C(0) or C(1) or C(2) or C(3) or C(4) or C(5) or C(6) or C(7) or C(8) or C(9) or C(10) or C(11) or C(12) or C(13) or C(14) or C(15) or C(16) or C(17) or C(18) or C(19) or C(20) or C(21) or C(22);
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
   Cexp <= CexpField - ("0" & (6 downto 1 => '1') & CisNormal);
   effectiveSub <= (negateAB xor Asgn xor Bsgn) xor (negateC xor Csgn);

   -- mantissa with the implicit 1 or 0 appended 
   Csig <= CisNormal & CsigField ;

    -- Computation of the exponent difference 
   expDiffPrepare <= ("00" & AexpField) + ("00" & BexpField) - ("000" & (6 downto 1 => '1') & AisNormal) - BisNormal;
   expDiff <= ("00" & CexpField) - expDiffPrepare - CisNormal;

    -- Addend shift datapath 
   -- Some logic to determine shift distance and tentative result exponent 
   tmpExpComp1 <= expDiff + "0000110000";
   expDiffVerySmall <= tmpExpComp1(9);  -- if expDiff < -2p
   tmpExpComp2 <= expDiff - "0000000011";
   expDiffSmall <= tmpExpComp2(9);  -- if expDiff < 3
   tmpExpComp3 <= expDiff - "0000011011";
   expDiffNotLarge <= tmpExpComp3(9);  -- if expDiff < p+3
   ShiftValue <= 
           "1001100" when expDiffVerySmall='1'
      else "0011011" - (expDiff (6 downto 0)) when expDiffNotLarge='1'
      else "0000000" ;
   RightShifterComponent: RightShifter24_by_max_76_F400_uid12
      port map ( clk  => clk,
                 S => ShiftValue,
                 X => Csig,
                 R => CsigShifted);
   sticky1 <= CsigShifted(0) or CsigShifted(1) or CsigShifted(2) or CsigShifted(3) or CsigShifted(4) or CsigShifted(5) or CsigShifted(6) or CsigShifted(7) or CsigShifted(8) or CsigShifted(9) or CsigShifted(10) or CsigShifted(11) or CsigShifted(12) or CsigShifted(13) or CsigShifted(14) or CsigShifted(15) or CsigShifted(16) or CsigShifted(17) or CsigShifted(18) or CsigShifted(19) or CsigShifted(20) or CsigShifted(21) or CsigShifted(22) or CsigShifted(23);
   CsigShiftedT <= CsigShifted(99 downto 24);

    -- Product datapath (using naive * operator, may improve in the future)
   P <= Asig * Bsig ;
   Paligned <= (25 downto 0 => '0') & P & "00";

    -- The sum at last 
   CsigInverted <= ('0' &CsigShiftedT) when effectiveSub_d1='0'  else ('1' & not CsigShiftedT);
   BigSum <= CsigInverted + ('0' & Paligned_d1) + effectiveSub_d1;  -- P +/-CeffectiveSub is a carry in
   BigSum2 <= CsigShiftedT - ('0' & Paligned_d1);
   RsgnTentative <= Asgn_d1 xor Bsgn_d1 xor negateAB_d1 xor BigSum(76);
   BigSumAbs <= BigSum(75 downto 0) when (BigSum2(76) or not effectiveSub_d1)='1' else BigSum2(75 downto 0);
   BigSumAbsLowerBits <= BigSumAbs(51 downto 0);
   IEEEFMA_8_23_F400_uid10LeadingZeroCounter: LZC_52_F400_uid14
      port map ( clk  => clk,
                 I => BigSumAbsLowerBits,
                 O => L);
   tmpExpCompRes1 <= (AexpPlusBexp(8) & AexpPlusBexp) + "0010000001";
   tmpExpCompRes2 <= tmpExpCompRes1_d3 - ((9 downto 6 => '0') & L);
   RisSubNormal <= (expDiffSmall_d3 or not CisNormal_d3) and  tmpExpCompRes2(9);
   RisZero <= expDiffSmall_d3 when L="110100"  else '0';
   RisSubNormalOrZero <= RisSubNormal or RisZero;
   Rsgn <=      (Asgn_d3 xor Bsgn_d3 xor negateAB_d3) and (Csgn_d3 xor negateC_d3) when ((AisZero_d3 or BisZero_d3) and CisZero_d3)='1'  -- negative only for -0 + -0 
      else '0' when RisZero='1'  -- covers 1-1 = +0
      else RsgnTentative_d2;  -- covers to underflow to zero case
   shiftValueCaseSubnormal <= AexpPlusBexp + "010011001";
   normShiftValue <= 
           L + "0011001" when (expDiffSmall_d3 and not RisSubNormal)='1'
      else shiftValueCaseSubnormal_d3(6 downto 0) when (expDiffSmall_d3 and RisSubNormal)='1'
      else ShiftValue_d3; -- undo inital shift
   NormalizationShifter: LeftShifter76_by_max_75_F400_uid16
      port map ( clk  => clk,
                 S => normShiftValue,
                 X => BigSumAbs,
                 R => BigSumNormd);
   -- TODO opt: push all the constant additions to exponentUpdate
   expTentative <= 
           "1110000011" when RisZero='1'
      else "1110000010" when RisSubNormal='1'
      else (AexpPlusBexp_d3(8) & AexpPlusBexp_d3 - ((9 downto 6 => '0') & L))  + "0000000011" when (expDiffSmall_d3 and not RisSubNormal)='1'
      else (Cexp_d3(7) & Cexp_d3(7) & Cexp_d3) + "0000000001" ;
   sticky2 <= BigSumNormd(0) or BigSumNormd(1) or BigSumNormd(2) or BigSumNormd(3) or BigSumNormd(4) or BigSumNormd(5) or BigSumNormd(6) or BigSumNormd(7) or BigSumNormd(8) or BigSumNormd(9) or BigSumNormd(10) or BigSumNormd(11) or BigSumNormd(12) or BigSumNormd(13) or BigSumNormd(14) or BigSumNormd(15) or BigSumNormd(16) or BigSumNormd(17) or BigSumNormd(18) or BigSumNormd(19) or BigSumNormd(20) or BigSumNormd(21) or BigSumNormd(22) or BigSumNormd(23) or BigSumNormd(24) or BigSumNormd(25) or BigSumNormd(26) or BigSumNormd(27) or BigSumNormd(28) or BigSumNormd(29) or BigSumNormd(30) or BigSumNormd(31) or BigSumNormd(32) or BigSumNormd(33) or BigSumNormd(34) or BigSumNormd(35) or BigSumNormd(36) or BigSumNormd(37) or BigSumNormd(38) or BigSumNormd(39) or BigSumNormd(40) or BigSumNormd(41) or BigSumNormd(42) or BigSumNormd(43) or BigSumNormd(44) or BigSumNormd(45) or BigSumNormd(46) or BigSumNormd(47) or BigSumNormd(48) or BigSumNormd(49);

   fracTentative <= BigSumNormd(76 downto 50);

    -- Last 2-bit normalization 
   fracLeadingBitsNormal <=  fracTentative(26 downto 25) ;
   fracLeadingBits <= "01" when RisSubNormal_d3='1' else  fracLeadingBitsNormal;
   fracResultNormd <=
           fracTentative(23 downto 1)  when fracLeadingBits = "00" 
      else fracTentative(24 downto 2)  when fracLeadingBits = "01" 
      else fracTentative(25 downto 3);
   fracResultRoundBit <=
           fracTentative(0) 	 when fracLeadingBits = "00" 
      else fracTentative(1)    when fracLeadingBits = "01" 
      else fracTentative(2) ;
   fracResultStickyBit <=
           sticky1_d5 or sticky2	 when fracLeadingBits = "00" 
      else fracTentative(0) or sticky1_d5 or sticky2    when fracLeadingBits = "01" 
      else fracTentative(1) or fracTentative(0) or  sticky1_d5 or sticky2;
   round <= fracResultRoundBit and (fracResultStickyBit or fracResultNormd(0));
   expUpdate <= "0001111101" when RisZero_d3 = '1'       -- bias - 2
         else   "0001111101" when fracLeadingBits = "00" -- bias - 2
         else   "0001111110" when fracLeadingBits = "01" -- bias - 1 
         else   "0001111111";                            -- bias 
   exponentResult1 <= expTentative_d3 + expUpdate;
   resultBeforeRound <= exponentResult1 & fracResultNormd;
   resultRounded <= resultBeforeRound + ((32 downto 1 => '0') & round);
   Roverflowed <= resultRounded(32) or resultRounded(31) or (resultRounded(30) and resultRounded(29) and resultRounded(28) and resultRounded(27) and resultRounded(26) and resultRounded(25) and resultRounded(24) and resultRounded(23));
   finalRisInf <= tentativeRisInf_d6 or Roverflowed; 
   Inf <= (30 downto 23 => '1') & (22 downto 0 => '0');
   NaN <= (30 downto 23 => '1') & (22 downto 0 => '1');
   R <= 
           Rsgn_d3 & Inf_d6 when ((not RisNaN_d6) and finalRisInf)='1'
      else '0'  & NaN_d6 when RisNaN_d6='1'
      else Rsgn_d3 & resultRounded(30 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                    RightShifter11_by_max_37_F400_uid20
-- VHDL generated for Kintex7 @ 400MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2008-2011), Florent de Dinechin (2008-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 1 cycles
-- Clock period (ns): 2.5
-- Target frequency (MHz): 400
-- Input signals: X S
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity RightShifter11_by_max_37_F400_uid20 is
    port (clk : in std_logic;
          X : in  std_logic_vector(10 downto 0);
          S : in  std_logic_vector(5 downto 0);
          R : out  std_logic_vector(47 downto 0)   );
end entity;

architecture arch of RightShifter11_by_max_37_F400_uid20 is
signal ps, ps_d1 :  std_logic_vector(5 downto 0);
signal level0 :  std_logic_vector(10 downto 0);
signal level1 :  std_logic_vector(11 downto 0);
signal level2 :  std_logic_vector(13 downto 0);
signal level3 :  std_logic_vector(17 downto 0);
signal level4 :  std_logic_vector(25 downto 0);
signal level5, level5_d1 :  std_logic_vector(41 downto 0);
signal level6 :  std_logic_vector(73 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            ps_d1 <=  ps;
            level5_d1 <=  level5;
         end if;
      end process;
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
   level6 <=  (31 downto 0 => '0') & level5_d1 when ps_d1(5) = '1' else    level5_d1 & (31 downto 0 => '0');
   R <= level6(73 downto 26);
end architecture;

--------------------------------------------------------------------------------
--                             LZC_26_F400_uid22
-- VHDL generated for Kintex7 @ 400MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin, Bogdan Pasca (2007)
--------------------------------------------------------------------------------
-- Pipeline depth: 2 cycles
-- Clock period (ns): 2.5
-- Target frequency (MHz): 400
-- Input signals: I
-- Output signals: O

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity LZC_26_F400_uid22 is
    port (clk : in std_logic;
          I : in  std_logic_vector(25 downto 0);
          O : out  std_logic_vector(4 downto 0)   );
end entity;

architecture arch of LZC_26_F400_uid22 is
signal level5 :  std_logic_vector(30 downto 0);
signal digit4, digit4_d1 :  std_logic;
signal level4, level4_d1 :  std_logic_vector(14 downto 0);
signal digit3 :  std_logic;
signal level3 :  std_logic_vector(6 downto 0);
signal digit2 :  std_logic;
signal level2, level2_d1 :  std_logic_vector(2 downto 0);
signal lowBits :  std_logic_vector(1 downto 0);
signal outHighBits, outHighBits_d1 :  std_logic_vector(2 downto 0);
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            digit4_d1 <=  digit4;
            level4_d1 <=  level4;
            level2_d1 <=  level2;
            outHighBits_d1 <=  outHighBits;
         end if;
      end process;
   -- pad input to the next power of two minus 1
   level5 <= I & "11111";
   -- Main iteration for large inputs
   digit4<= '1' when level5(30 downto 15) = "0000000000000000" else '0';
   level4<= level5(14 downto 0) when digit4='1' else level5(30 downto 16);
   digit3<= '1' when level4_d1(14 downto 7) = "00000000" else '0';
   level3<= level4_d1(6 downto 0) when digit3='1' else level4_d1(14 downto 8);
   digit2<= '1' when level3(6 downto 3) = "0000" else '0';
   level2<= level3(2 downto 0) when digit2='1' else level3(6 downto 4);
   -- Finish counting with one LUT
   with level2_d1  select  lowBits <= 
      "11" when "000",
      "10" when "001",
      "01" when "010",
      "01" when "011",
      "00" when others;
   outHighBits <= digit4_d1 & digit3 & digit2 & "";
   O <= outHighBits_d1 & lowBits ;
end architecture;

--------------------------------------------------------------------------------
--                     LeftShifter37_by_max_36_F400_uid24
-- VHDL generated for Kintex7 @ 400MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Bogdan Pasca (2008-2011), Florent de Dinechin (2008-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 2 cycles
-- Clock period (ns): 2.5
-- Target frequency (MHz): 400
-- Input signals: X S
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity LeftShifter37_by_max_36_F400_uid24 is
    port (clk : in std_logic;
          X : in  std_logic_vector(36 downto 0);
          S : in  std_logic_vector(5 downto 0);
          R : out  std_logic_vector(72 downto 0)   );
end entity;

architecture arch of LeftShifter37_by_max_36_F400_uid24 is
signal ps, ps_d1, ps_d2 :  std_logic_vector(5 downto 0);
signal level0, level0_d1, level0_d2 :  std_logic_vector(36 downto 0);
signal level1 :  std_logic_vector(37 downto 0);
signal level2 :  std_logic_vector(39 downto 0);
signal level3, level3_d1 :  std_logic_vector(43 downto 0);
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
            level0_d2 <=  level0_d1;
            level3_d1 <=  level3;
            level5_d1 <=  level5;
         end if;
      end process;
   ps<= S;
   level0<= X;
   level1<= level0_d2 & (0 downto 0 => '0') when ps(0)= '1' else     (0 downto 0 => '0') & level0_d2;
   R <= level6(72 downto 0);
   level2<= level1 & (1 downto 0 => '0') when ps(1)= '1' else     (1 downto 0 => '0') & level1;
   R <= level6(72 downto 0);
   level3<= level2 & (3 downto 0 => '0') when ps(2)= '1' else     (3 downto 0 => '0') & level2;
   R <= level6(72 downto 0);
   level4<= level3_d1 & (7 downto 0 => '0') when ps_d1(3)= '1' else     (7 downto 0 => '0') & level3_d1;
   R <= level6(72 downto 0);
   level5<= level4 & (15 downto 0 => '0') when ps_d1(4)= '1' else     (15 downto 0 => '0') & level4;
   R <= level6(72 downto 0);
   level6<= level5_d1 & (31 downto 0 => '0') when ps_d2(5)= '1' else     (31 downto 0 => '0') & level5_d1;
   R <= level6(72 downto 0);
end architecture;

--------------------------------------------------------------------------------
--                                   FMA_H
--                         (IEEEFMA_5_10_F400_uid18)
-- Inputs: this FMA computes A*B+C
-- VHDL generated for Kintex7 @ 400MHz
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Florent de Dinechin (2009-2019)
--------------------------------------------------------------------------------
-- Pipeline depth: 5 cycles
-- Clock period (ns): 2.5
-- Target frequency (MHz): 400
-- Input signals: A B C negateAB negateC RndMode
-- Output signals: R

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
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
   component RightShifter11_by_max_37_F400_uid20 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(10 downto 0);
             S : in  std_logic_vector(5 downto 0);
             R : out  std_logic_vector(47 downto 0)   );
   end component;

   component LZC_26_F400_uid22 is
      port ( clk : in std_logic;
             I : in  std_logic_vector(25 downto 0);
             O : out  std_logic_vector(4 downto 0)   );
   end component;

   component LeftShifter37_by_max_36_F400_uid24 is
      port ( clk : in std_logic;
             X : in  std_logic_vector(36 downto 0);
             S : in  std_logic_vector(5 downto 0);
             R : out  std_logic_vector(72 downto 0)   );
   end component;

signal Asgn, Asgn_d1, Asgn_d2, Asgn_d3 :  std_logic;
signal AexpField :  std_logic_vector(4 downto 0);
signal AsigField :  std_logic_vector(9 downto 0);
signal AisNormal :  std_logic;
signal AisInfOrNaN :  std_logic;
signal AhasNonNullSig :  std_logic;
signal AisZero, AisZero_d1, AisZero_d2, AisZero_d3 :  std_logic;
signal AisInf :  std_logic;
signal AisNaN :  std_logic;
signal Bsgn, Bsgn_d1, Bsgn_d2, Bsgn_d3 :  std_logic;
signal BexpField :  std_logic_vector(4 downto 0);
signal BsigField :  std_logic_vector(9 downto 0);
signal BisNormal :  std_logic;
signal BisInfOrNaN :  std_logic;
signal BhasNonNullSig :  std_logic;
signal BisZero, BisZero_d1, BisZero_d2, BisZero_d3 :  std_logic;
signal BisInf :  std_logic;
signal BisNaN :  std_logic;
signal Aexp :  std_logic_vector(4 downto 0);
signal Bexp :  std_logic_vector(4 downto 0);
signal Asig :  std_logic_vector(10 downto 0);
signal Bsig :  std_logic_vector(10 downto 0);
signal AexpPlusBexp, AexpPlusBexp_d1, AexpPlusBexp_d2, AexpPlusBexp_d3 :  std_logic_vector(5 downto 0);
signal Csgn, Csgn_d1, Csgn_d2, Csgn_d3 :  std_logic;
signal CexpField :  std_logic_vector(4 downto 0);
signal CsigField :  std_logic_vector(9 downto 0);
signal CisNormal, CisNormal_d1, CisNormal_d2, CisNormal_d3 :  std_logic;
signal CisInfOrNaN :  std_logic;
signal ChasNonNullSig :  std_logic;
signal CisZero, CisZero_d1, CisZero_d2, CisZero_d3 :  std_logic;
signal CisInf :  std_logic;
signal CisNaN :  std_logic;
signal RisNaN, RisNaN_d1, RisNaN_d2, RisNaN_d3, RisNaN_d4, RisNaN_d5 :  std_logic;
signal tentativeRisInf, tentativeRisInf_d1, tentativeRisInf_d2, tentativeRisInf_d3, tentativeRisInf_d4, tentativeRisInf_d5 :  std_logic;
signal Cexp, Cexp_d1, Cexp_d2, Cexp_d3 :  std_logic_vector(4 downto 0);
signal effectiveSub, effectiveSub_d1 :  std_logic;
signal Csig :  std_logic_vector(10 downto 0);
signal expDiffPrepare :  std_logic_vector(6 downto 0);
signal expDiff :  std_logic_vector(6 downto 0);
signal tmpExpComp1 :  std_logic_vector(6 downto 0);
signal expDiffVerySmall :  std_logic;
signal tmpExpComp2 :  std_logic_vector(6 downto 0);
signal expDiffSmall, expDiffSmall_d1, expDiffSmall_d2, expDiffSmall_d3 :  std_logic;
signal tmpExpComp3 :  std_logic_vector(6 downto 0);
signal expDiffNotLarge :  std_logic;
signal ShiftValue, ShiftValue_d1, ShiftValue_d2, ShiftValue_d3 :  std_logic_vector(5 downto 0);
signal CsigShifted :  std_logic_vector(47 downto 0);
signal sticky1, sticky1_d1, sticky1_d2, sticky1_d3, sticky1_d4 :  std_logic;
signal CsigShiftedT :  std_logic_vector(36 downto 0);
signal P :  std_logic_vector(21 downto 0);
signal Paligned, Paligned_d1 :  std_logic_vector(36 downto 0);
signal CsigInverted :  std_logic_vector(37 downto 0);
signal BigSum :  std_logic_vector(37 downto 0);
signal BigSum2 :  std_logic_vector(37 downto 0);
signal RsgnTentative, RsgnTentative_d1, RsgnTentative_d2 :  std_logic;
signal BigSumAbs :  std_logic_vector(36 downto 0);
signal BigSumAbsLowerBits :  std_logic_vector(25 downto 0);
signal L :  std_logic_vector(4 downto 0);
signal tmpExpCompRes1, tmpExpCompRes1_d1, tmpExpCompRes1_d2, tmpExpCompRes1_d3 :  std_logic_vector(6 downto 0);
signal tmpExpCompRes2 :  std_logic_vector(6 downto 0);
signal RisSubNormal, RisSubNormal_d1, RisSubNormal_d2 :  std_logic;
signal RisZero, RisZero_d1, RisZero_d2 :  std_logic;
signal RisSubNormalOrZero :  std_logic;
signal Rsgn, Rsgn_d1, Rsgn_d2 :  std_logic;
signal shiftValueCaseSubnormal, shiftValueCaseSubnormal_d1, shiftValueCaseSubnormal_d2, shiftValueCaseSubnormal_d3 :  std_logic_vector(5 downto 0);
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
signal Inf, Inf_d1, Inf_d2, Inf_d3, Inf_d4, Inf_d5 :  std_logic_vector(14 downto 0);
signal NaN, NaN_d1, NaN_d2, NaN_d3, NaN_d4, NaN_d5 :  std_logic_vector(14 downto 0);
signal negateAB_d1, negateAB_d2, negateAB_d3 :  std_logic;
signal negateC_d1, negateC_d2, negateC_d3 :  std_logic;
begin
   process(clk)
      begin
         if clk'event and clk = '1' then
            Asgn_d1 <=  Asgn;
            Asgn_d2 <=  Asgn_d1;
            Asgn_d3 <=  Asgn_d2;
            AisZero_d1 <=  AisZero;
            AisZero_d2 <=  AisZero_d1;
            AisZero_d3 <=  AisZero_d2;
            Bsgn_d1 <=  Bsgn;
            Bsgn_d2 <=  Bsgn_d1;
            Bsgn_d3 <=  Bsgn_d2;
            BisZero_d1 <=  BisZero;
            BisZero_d2 <=  BisZero_d1;
            BisZero_d3 <=  BisZero_d2;
            AexpPlusBexp_d1 <=  AexpPlusBexp;
            AexpPlusBexp_d2 <=  AexpPlusBexp_d1;
            AexpPlusBexp_d3 <=  AexpPlusBexp_d2;
            Csgn_d1 <=  Csgn;
            Csgn_d2 <=  Csgn_d1;
            Csgn_d3 <=  Csgn_d2;
            CisNormal_d1 <=  CisNormal;
            CisNormal_d2 <=  CisNormal_d1;
            CisNormal_d3 <=  CisNormal_d2;
            CisZero_d1 <=  CisZero;
            CisZero_d2 <=  CisZero_d1;
            CisZero_d3 <=  CisZero_d2;
            RisNaN_d1 <=  RisNaN;
            RisNaN_d2 <=  RisNaN_d1;
            RisNaN_d3 <=  RisNaN_d2;
            RisNaN_d4 <=  RisNaN_d3;
            RisNaN_d5 <=  RisNaN_d4;
            tentativeRisInf_d1 <=  tentativeRisInf;
            tentativeRisInf_d2 <=  tentativeRisInf_d1;
            tentativeRisInf_d3 <=  tentativeRisInf_d2;
            tentativeRisInf_d4 <=  tentativeRisInf_d3;
            tentativeRisInf_d5 <=  tentativeRisInf_d4;
            Cexp_d1 <=  Cexp;
            Cexp_d2 <=  Cexp_d1;
            Cexp_d3 <=  Cexp_d2;
            effectiveSub_d1 <=  effectiveSub;
            expDiffSmall_d1 <=  expDiffSmall;
            expDiffSmall_d2 <=  expDiffSmall_d1;
            expDiffSmall_d3 <=  expDiffSmall_d2;
            ShiftValue_d1 <=  ShiftValue;
            ShiftValue_d2 <=  ShiftValue_d1;
            ShiftValue_d3 <=  ShiftValue_d2;
            sticky1_d1 <=  sticky1;
            sticky1_d2 <=  sticky1_d1;
            sticky1_d3 <=  sticky1_d2;
            sticky1_d4 <=  sticky1_d3;
            Paligned_d1 <=  Paligned;
            RsgnTentative_d1 <=  RsgnTentative;
            RsgnTentative_d2 <=  RsgnTentative_d1;
            tmpExpCompRes1_d1 <=  tmpExpCompRes1;
            tmpExpCompRes1_d2 <=  tmpExpCompRes1_d1;
            tmpExpCompRes1_d3 <=  tmpExpCompRes1_d2;
            RisSubNormal_d1 <=  RisSubNormal;
            RisSubNormal_d2 <=  RisSubNormal_d1;
            RisZero_d1 <=  RisZero;
            RisZero_d2 <=  RisZero_d1;
            Rsgn_d1 <=  Rsgn;
            Rsgn_d2 <=  Rsgn_d1;
            shiftValueCaseSubnormal_d1 <=  shiftValueCaseSubnormal;
            shiftValueCaseSubnormal_d2 <=  shiftValueCaseSubnormal_d1;
            shiftValueCaseSubnormal_d3 <=  shiftValueCaseSubnormal_d2;
            expTentative_d1 <=  expTentative;
            expTentative_d2 <=  expTentative_d1;
            Inf_d1 <=  Inf;
            Inf_d2 <=  Inf_d1;
            Inf_d3 <=  Inf_d2;
            Inf_d4 <=  Inf_d3;
            Inf_d5 <=  Inf_d4;
            NaN_d1 <=  NaN;
            NaN_d2 <=  NaN_d1;
            NaN_d3 <=  NaN_d2;
            NaN_d4 <=  NaN_d3;
            NaN_d5 <=  NaN_d4;
            negateAB_d1 <=  negateAB;
            negateAB_d2 <=  negateAB_d1;
            negateAB_d3 <=  negateAB_d2;
            negateC_d1 <=  negateC;
            negateC_d2 <=  negateC_d1;
            negateC_d3 <=  negateC_d2;
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
   RightShifterComponent: RightShifter11_by_max_37_F400_uid20
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
   CsigInverted <= ('0' &CsigShiftedT) when effectiveSub_d1='0'  else ('1' & not CsigShiftedT);
   BigSum <= CsigInverted + ('0' & Paligned_d1) + effectiveSub_d1;  -- P +/-CeffectiveSub is a carry in
   BigSum2 <= CsigShiftedT - ('0' & Paligned_d1);
   RsgnTentative <= Asgn_d1 xor Bsgn_d1 xor negateAB_d1 xor BigSum(37);
   BigSumAbs <= BigSum(36 downto 0) when (BigSum2(37) or not effectiveSub_d1)='1' else BigSum2(36 downto 0);
   BigSumAbsLowerBits <= BigSumAbs(25 downto 0);
   IEEEFMA_5_10_F400_uid18LeadingZeroCounter: LZC_26_F400_uid22
      port map ( clk  => clk,
                 I => BigSumAbsLowerBits,
                 O => L);
   tmpExpCompRes1 <= (AexpPlusBexp(5) & AexpPlusBexp) + "0010001";
   tmpExpCompRes2 <= tmpExpCompRes1_d3 - ((6 downto 5 => '0') & L);
   RisSubNormal <= (expDiffSmall_d3 or not CisNormal_d3) and  tmpExpCompRes2(6);
   RisZero <= expDiffSmall_d3 when L="11010"  else '0';
   RisSubNormalOrZero <= RisSubNormal or RisZero;
   Rsgn <=      (Asgn_d3 xor Bsgn_d3 xor negateAB_d3) and (Csgn_d3 xor negateC_d3) when ((AisZero_d3 or BisZero_d3) and CisZero_d3)='1'  -- negative only for -0 + -0 
      else '0' when RisZero='1'  -- covers 1-1 = +0
      else RsgnTentative_d2;  -- covers to underflow to zero case
   shiftValueCaseSubnormal <= AexpPlusBexp + "011100";
   normShiftValue <= 
           L + "001100" when (expDiffSmall_d3 and not RisSubNormal)='1'
      else shiftValueCaseSubnormal_d3(5 downto 0) when (expDiffSmall_d3 and RisSubNormal)='1'
      else ShiftValue_d3; -- undo inital shift
   NormalizationShifter: LeftShifter37_by_max_36_F400_uid24
      port map ( clk  => clk,
                 S => normShiftValue,
                 X => BigSumAbs,
                 R => BigSumNormd);
   -- TODO opt: push all the constant additions to exponentUpdate
   expTentative <= 
           "1110011" when RisZero='1'
      else "1110010" when RisSubNormal='1'
      else (AexpPlusBexp_d3(5) & AexpPlusBexp_d3 - ((6 downto 5 => '0') & L))  + "0000011" when (expDiffSmall_d3 and not RisSubNormal)='1'
      else (Cexp_d3(4) & Cexp_d3(4) & Cexp_d3) + "0000001" ;
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
           sticky1_d4 or sticky2	 when fracLeadingBits = "00" 
      else fracTentative(0) or sticky1_d4 or sticky2    when fracLeadingBits = "01" 
      else fracTentative(1) or fracTentative(0) or  sticky1_d4 or sticky2;
   round <= fracResultRoundBit and (fracResultStickyBit or fracResultNormd(0));
   expUpdate <= "0001101" when RisZero_d2 = '1'       -- bias - 2
         else   "0001101" when fracLeadingBits = "00" -- bias - 2
         else   "0001110" when fracLeadingBits = "01" -- bias - 1 
         else   "0001111";                            -- bias 
   exponentResult1 <= expTentative_d2 + expUpdate;
   resultBeforeRound <= exponentResult1 & fracResultNormd;
   resultRounded <= resultBeforeRound + ((16 downto 1 => '0') & round);
   Roverflowed <= resultRounded(16) or resultRounded(15) or (resultRounded(14) and resultRounded(13) and resultRounded(12) and resultRounded(11) and resultRounded(10));
   finalRisInf <= tentativeRisInf_d5 or Roverflowed; 
   Inf <= (14 downto 10 => '1') & (9 downto 0 => '0');
   NaN <= (14 downto 10 => '1') & (9 downto 0 => '1');
   R <= 
           Rsgn_d2 & Inf_d5 when ((not RisNaN_d5) and finalRisInf)='1'
      else '0'  & NaN_d5 when RisNaN_d5='1'
      else Rsgn_d2 & resultRounded(14 downto 0);
end architecture;

