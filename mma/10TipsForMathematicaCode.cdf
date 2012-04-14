(* Content-type: application/vnd.wolfram.player *)

(*** Wolfram Notebook File ***)
(* http://www.wolfram.com/nb *)

(* CreatedBy='Mathematica 8.0' *)

(*CacheID: 234*)
(* Internal cache information:
NotebookFileLineBreakTest
NotebookFileLineBreakTest
NotebookDataPosition[       152,          7]
NotebookDataLength[     83593,       2215]
NotebookOptionsPosition[     74940,       1953]
NotebookOutlinePosition[     78292,       2037]
CellTagsIndexPosition[     78249,       2034]
WindowFrame->Normal*)

(* Beginning of Notebook Content *)
Notebook[{

Cell[CellGroupData[{
Cell[TextData[{
 "10 Tips for Writing Fast ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " Code"
}], "Title",
 CellChangeTimes->{{3.518432566138583*^9, 3.518432574658435*^9}, {
   3.5184354853524756`*^9, 3.5184354883837786`*^9}, 3.5184378384377604`*^9, {
   3.530359482386485*^9, 3.5303594827764854`*^9}, {3.5316727489436626`*^9, 
   3.53167276458851*^9}}],

Cell["November 17, 2011", "Date",
 CellChangeTimes->{3.5305138478379183`*^9},
 CellID->70619275],

Cell["Jon McLoone, International Business & Strategic Development ", "Author",
 CellChangeTimes->{3.5305138478379183`*^9, 3.5305243512917323`*^9},
 CellID->17557214],

Cell[TextData[{
 "When people tell me that ",
 StyleBox[ButtonBox["Mathematica",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://www.wolfram.com/mathematica"], None},
  ButtonNote->"http://www.wolfram.com/mathematica"],
  FontSlant->"Italic"],
 " isn\[CloseCurlyQuote]t fast enough, I usually ask to see the offending \
code and often find that the problem isn\[CloseCurlyQuote]t a lack in ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 "\[CloseCurlyQuote]s performance, but sub-optimal use of ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 ". I thought I would share the list of things that I look for first when \
trying to optimize ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " code."
}], "Text",
 CellChangeTimes->{{3.527775826528042*^9, 3.5277759214260087`*^9}, {
  3.530359517814147*^9, 3.5303595180325475`*^9}, {3.5303610411990232`*^9, 
  3.530361063850263*^9}, {3.530513926894823*^9, 3.5305139540055337`*^9}, {
  3.531742933542495*^9, 3.531742945052101*^9}, {3.5317479944336233`*^9, 
  3.531747994435823*^9}}],

Cell[CellGroupData[{

Cell["\<\
1. Use floating-point numbers if you can, and use them early.\
\>", "Section",
 CellChangeTimes->{{3.5184325766916385`*^9, 3.5184326012040896`*^9}, {
   3.5277764737771792`*^9, 3.5277764806411915`*^9}, 3.5305143045665865`*^9, {
   3.531672793467746*^9, 3.5316727974939337`*^9}, {3.53219463574444*^9, 
   3.5321946358290854`*^9}}],

Cell[TextData[{
 "Of the most common issues that I see when I review slow code is that the \
programmer has inadvertently asked ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " to do things more carefully than needed. Unnecessary use of exact \
arithmetic is the most common case. \n\nIn most numerical software, there is \
no such thing as exact arithmetic. 1/3 is the same thing as 0.33333333333333. \
That difference can be pretty important when you hit nasty, numerically \
unstable problems, but in the majority of tasks, floating-point numbers are \
good enough and, importantly, much faster. In ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " any number with a decimal point and less than 16 digits of input is \
automatically treated as a machine float, so always use the decimal point if \
you want speed ahead of accuracy (e.g. enter a third as 1./3.). Here is a \
simple example where working with floating-point numbers is nearly 40 times \
faster than doing the computation exactly and then converting the result to a \
decimal afterward. And in this case it gets the same result."
}], "Text",
 CellChangeTimes->{{3.518432605860555*^9, 3.5184327617791452`*^9}, {
   3.5184328061585827`*^9, 3.5184328256455317`*^9}, {3.51843663211314*^9, 
   3.5184366985567837`*^9}, {3.5184370154674716`*^9, 
   3.5184371794318666`*^9}, {3.518441461183013*^9, 3.518441509319826*^9}, {
   3.5277759468540535`*^9, 3.5277759632184825`*^9}, {3.5277760053697567`*^9, 
   3.52777602446419*^9}, {3.5277761397015924`*^9, 3.5277761506216116`*^9}, {
   3.5277762280757475`*^9, 3.527776234612159*^9}, {3.5277762752970304`*^9, 
   3.527776444277527*^9}, {3.5277765078008385`*^9, 3.5277767141902018`*^9}, {
   3.5277767473246593`*^9, 3.5277767559202747`*^9}, {3.530340566284503*^9, 
   3.5303405944425526`*^9}, {3.5303595675470343`*^9, 3.530359568015035*^9}, {
   3.5305139923153644`*^9, 3.5305141087000017`*^9}, {3.530524374523055*^9, 
   3.5305243925048532`*^9}, {3.5305245044970512`*^9, 3.530524505007102*^9}, {
   3.531672819056211*^9, 3.531672901240128*^9}, {3.531673093175789*^9, 
   3.5316731107531424`*^9}, {3.5317429612986794`*^9, 3.5317429630512753`*^9}, 
   3.531747573816592*^9}],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{"N", "[", 
   RowBox[{"Det", "[", 
    RowBox[{"Table", "[", 
     RowBox[{
      RowBox[{"1", "/", 
       RowBox[{"(", 
        RowBox[{"1", "+", 
         RowBox[{"Abs", "[", 
          RowBox[{"i", "-", "j"}], "]"}]}], ")"}]}], ",", 
      RowBox[{"{", 
       RowBox[{"i", ",", "1", ",", "150"}], "}"}], ",", 
      RowBox[{"{", 
       RowBox[{"j", ",", "1", ",", "150"}], "}"}]}], "]"}], "]"}], "]"}], "//",
   "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.5243691652914495`*^9, 3.5243692146967363`*^9}, {
  3.5243692650224247`*^9, 3.5243692686572313`*^9}, {3.524369299077285*^9, 
  3.524369377935423*^9}, {3.524369408464677*^9, 3.5243695142172623`*^9}, {
  3.524369545042917*^9, 3.524369557164138*^9}, {3.524369599377812*^9, 
  3.5243696320910697`*^9}, {3.530359617857123*^9, 3.53035962195993*^9}, {
  3.5305141305271845`*^9, 3.53051413718285*^9}},
 CellLabel->"In[1]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"3.9469012`8.047801248639436", ",", "9.303106865686802`*^-21"}], 
  "}"}]], "Output",
 CellChangeTimes->{3.5243696362094765`*^9, 3.5277766298554535`*^9, 
  3.5306113630871897`*^9},
 CellLabel->"Out[1]="]
}, Open  ]],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{"Det", "[", 
   RowBox[{"Table", "[", 
    RowBox[{
     RowBox[{"1", "/", 
      RowBox[{"(", 
       RowBox[{"1.", "+", 
        RowBox[{"Abs", "[", 
         RowBox[{"i", "-", "j"}], "]"}]}], ")"}]}], ",", 
     RowBox[{"{", 
      RowBox[{"i", ",", "1.", ",", "150."}], "}"}], ",", 
     RowBox[{"{", 
      RowBox[{"j", ",", "1.", ",", "150."}], "}"}]}], "]"}], "]"}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.5243692251175547`*^9, 3.5243692328707685`*^9}, {
  3.52436933604935*^9, 3.5243693672182045`*^9}, {3.5243694006646633`*^9, 
  3.524369400992264*^9}, {3.5243695744957685`*^9, 3.5243695943234034`*^9}, {
  3.530514140168148*^9, 3.5305141427684083`*^9}},
 CellLabel->"In[2]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"0.078002`6.343650731799636", ",", "9.303106865686791`*^-21"}], 
  "}"}]], "Output",
 CellChangeTimes->{{3.5243693440209637`*^9, 3.5243693678110056`*^9}, 
   3.5243694018346653`*^9, {3.5243695784425755`*^9, 3.5243695949474044`*^9}, 
   3.524369636240677*^9, 3.527776630027054*^9, 3.5306113670808926`*^9},
 CellLabel->"Out[2]="]
}, Open  ]],

Cell[TextData[{
 "The same is true for symbolic computation. If you don\[CloseCurlyQuote]t \
care about the symbolic answer and are not worried about stability, then \
substitute numerical values as soon as you can. For example, solving this \
polynomial symbolically before substituting the values in causes ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " to produce a five-page-long intermediate symbolic expression."
}], "Text",
 CellChangeTimes->{{3.527776765015091*^9, 3.527776788898733*^9}, {
  3.5277768631548634`*^9, 3.527776917692559*^9}, {3.530340625595807*^9, 
  3.530340648605848*^9}, {3.5305141658317146`*^9, 3.5305142433454647`*^9}, {
  3.530524395503153*^9, 3.530524397343337*^9}, {3.531673121786882*^9, 
  3.5316731479756927`*^9}}],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"Solve", "[", 
    RowBox[{
     RowBox[{
      RowBox[{
       RowBox[{"a", " ", 
        RowBox[{"x", "^", "4"}]}], "+", 
       RowBox[{"b", " ", 
        RowBox[{"x", "^", "3"}]}], "+", 
       RowBox[{"c", " ", "x"}], "+", "d"}], "\[Equal]", "0"}], ",", "x"}], 
    "]"}], "/.", 
   RowBox[{"{", 
    RowBox[{
     RowBox[{"a", "\[Rule]", "2."}], ",", 
     RowBox[{"b", "\[Rule]", "4."}], ",", 
     RowBox[{"c", "\[Rule]", "7."}], ",", 
     RowBox[{"d", "\[Rule]", "11."}]}], "}"}]}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.5277767903339353`*^9, 3.5277768327660093`*^9}, {
  3.530514254708601*^9, 3.5305142578279133`*^9}},
 CellLabel->"In[3]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"0.1872048`6.723861973511243", ",", 
   RowBox[{"{", 
    RowBox[{
     RowBox[{"{", 
      RowBox[{"x", "\[Rule]", 
       RowBox[{"-", "2.2069277279263058`"}]}], "}"}], ",", 
     RowBox[{"{", 
      RowBox[{"x", "\[Rule]", 
       RowBox[{"-", "1.1843045095726947`"}]}], "}"}], ",", 
     RowBox[{"{", 
      RowBox[{"x", "\[Rule]", 
       RowBox[{"0.6956161187495002`", "\[VeryThinSpace]", "-", 
        RowBox[{"1.2729632235481954`", " ", "\[ImaginaryI]"}]}]}], "}"}], ",", 
     RowBox[{"{", 
      RowBox[{"x", "\[Rule]", 
       RowBox[{"0.6956161187495002`", "\[VeryThinSpace]", "+", 
        RowBox[{"1.2729632235481954`", " ", "\[ImaginaryI]"}]}]}], "}"}]}], 
    "}"}]}], "}"}]], "Output",
 CellChangeTimes->{3.527776833764412*^9, 3.5306113720730205`*^9},
 CellLabel->"Out[3]="]
}, Open  ]],

Cell[TextData[{
 "But do the substitution first, and ",
 StyleBox[ButtonBox["Solve",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Solve.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Solve.html"], 
  "FunctionLink"],
 " will use fast numerical methods."
}], "Text",
 CellChangeTimes->{{3.5277769208125644`*^9, 3.527776944618206*^9}, {
   3.530357101923503*^9, 3.530357104575508*^9}, 3.530524399342537*^9, {
   3.5316731643695307`*^9, 3.531673175470851*^9}, {3.5316732069555264`*^9, 
   3.531673206956934*^9}}],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{"Solve", "[", 
   RowBox[{
    RowBox[{
     RowBox[{
      RowBox[{
       RowBox[{"a", " ", 
        RowBox[{"x", "^", "4"}]}], "+", 
       RowBox[{"b", " ", 
        RowBox[{"x", "^", "3"}]}], "+", 
       RowBox[{"c", " ", "x"}], "+", "d"}], "\[Equal]", "0"}], "/.", 
     RowBox[{"{", 
      RowBox[{
       RowBox[{"a", "\[Rule]", "2."}], ",", 
       RowBox[{"b", "\[Rule]", "4."}], ",", 
       RowBox[{"c", "\[Rule]", "7."}], ",", 
       RowBox[{"d", "\[Rule]", "11."}]}], "}"}]}], ",", "x"}], "]"}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.5277768418764257`*^9, 3.527776852063244*^9}, {
  3.530514260477178*^9, 3.530514266580788*^9}},
 CellLabel->"In[4]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"0.0468012`6.12180198218328", ",", 
   RowBox[{"{", 
    RowBox[{
     RowBox[{"{", 
      RowBox[{"x", "\[Rule]", 
       RowBox[{"-", "2.2069277279263058`"}]}], "}"}], ",", 
     RowBox[{"{", 
      RowBox[{"x", "\[Rule]", 
       RowBox[{"-", "1.1843045095726952`"}]}], "}"}], ",", 
     RowBox[{"{", 
      RowBox[{"x", "\[Rule]", 
       RowBox[{"0.6956161187495004`", "\[VeryThinSpace]", "-", 
        RowBox[{"1.2729632235481954`", " ", "\[ImaginaryI]"}]}]}], "}"}], ",", 
     RowBox[{"{", 
      RowBox[{"x", "\[Rule]", 
       RowBox[{"0.6956161187495004`", "\[VeryThinSpace]", "+", 
        RowBox[{"1.2729632235481954`", " ", "\[ImaginaryI]"}]}]}], "}"}]}], 
    "}"}]}], "}"}]], "Output",
 CellChangeTimes->{3.527776852968045*^9, 3.5306113753959055`*^9},
 CellLabel->"Out[4]="]
}, Open  ]],

Cell["\<\
When working with lists of data, be consistent in your use of reals. It only \
takes one exact value to cause the whole dataset to have to be held in a more \
flexible but less efficient form.\
\>", "Text",
 CellChangeTimes->{{3.530346163429415*^9, 3.530346203724286*^9}, {
   3.53034626305119*^9, 3.530346274876011*^9}, {3.530346316574884*^9, 
   3.530346339475724*^9}, {3.530357119301934*^9, 3.530357120690336*^9}, {
   3.5303571642466125`*^9, 3.530357203000081*^9}, {3.5303596737832212`*^9, 
   3.5303596876516457`*^9}, 3.530524405815184*^9, 3.53167404373841*^9}],

Cell[CellGroupData[{

Cell[BoxData[{
 RowBox[{
  RowBox[{"data", "=", 
   RowBox[{"RandomReal", "[", 
    RowBox[{"1", ",", 
     RowBox[{"{", "1000000", "}"}]}], "]"}]}], ";"}], "\[IndentingNewLine]", 
 RowBox[{"ByteCount", "[", 
  RowBox[{"Append", "[", 
   RowBox[{"data", ",", "1."}], "]"}], "]"}]}], "Input",
 CellChangeTimes->{{3.5303462911156397`*^9, 3.5303462970436497`*^9}},
 CellLabel->"In[5]:="],

Cell[BoxData["8000176"], "Output",
 CellChangeTimes->{3.530346297808051*^9, 3.530611381994875*^9},
 CellLabel->"Out[6]="]
}, Open  ]],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{"ByteCount", "[", 
  RowBox[{"Append", "[", 
   RowBox[{"data", ",", "1"}], "]"}], "]"}]], "Input",
 CellChangeTimes->{{3.5303462388243475`*^9, 3.5303462484027643`*^9}},
 CellLabel->"In[7]:="],

Cell[BoxData["32000072"], "Output",
 CellChangeTimes->{3.5303462493075657`*^9, 3.5306113835549145`*^9},
 CellLabel->"Out[7]="]
}, Open  ]]
}, Open  ]],

Cell[CellGroupData[{

Cell[TextData[{
 "2. ",
 StyleBox["Learn", "Title",
  FontSize->20,
  FontColor->RGBColor[0., 0., 0.]],
 " about ",
 StyleBox["Compile", "Program"],
 StyleBox["...", "Program",
  FontFamily->"Helvetica"]
}], "Section",
 CellChangeTimes->{{3.5184328635503216`*^9, 3.518432872207187*^9}, {
  3.531674116362385*^9, 3.531674140615498*^9}, {3.5321946395723743`*^9, 
  3.5321946400526*^9}}],

Cell[TextData[{
 "The ",
 StyleBox[ButtonBox["Compile",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Compile.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Compile.html"], 
  "Program"],
 " function takes ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " code and allows you to pre-declare the types (real, complex, etc.) and \
structures (value, list, matrix, etc.) of input arguments. This takes away \
some of the flexibility of the ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " language, but freed from having to worry about \[OpenCurlyDoubleQuote]What \
if the argument was symbolic?\[CloseCurlyDoubleQuote] and the like, ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " can optimize the program and create a byte code to run on its own virtual \
machine. Not everything can be compiled, and very simple code might not \
benefit, but complex low-level numerical code can get a really big speedup.\n\
\nHere is an example:"
}], "Text",
 CellChangeTimes->{{3.5184328813040967`*^9, 3.518433004069372*^9}, {
   3.5184330371266775`*^9, 3.5184330725202165`*^9}, {3.518437191017025*^9, 
   3.5184372158425074`*^9}, {3.5277769857398787`*^9, 3.527777023616745*^9}, {
   3.5277770569852037`*^9, 3.527777062070812*^9}, {3.5303597152958937`*^9, 
   3.5303597434695435`*^9}, {3.5305143610972385`*^9, 3.530514395800709*^9}, {
   3.530523283221281*^9, 3.530523283223281*^9}, 3.530524415265129*^9, {
   3.5306020390928507`*^9, 3.53060204798874*^9}, {3.530612934801506*^9, 
   3.530612943600132*^9}, {3.531674098234971*^9, 3.531674107936288*^9}, {
   3.531674196407691*^9, 3.531674238835453*^9}, {3.53174763126728*^9, 
   3.53174763354841*^9}}],

Cell[BoxData[
 RowBox[{
  RowBox[{"arg", "=", 
   RowBox[{"Range", "[", " ", 
    RowBox[{
     RowBox[{"-", "50."}], ",", "50", ",", " ", "0.25"}], "]"}]}], 
  ";"}]], "Input",
 CellChangeTimes->{{3.530601497766723*^9, 3.5306015037673235`*^9}, 
   3.5306018815751004`*^9, {3.5306019154564877`*^9, 3.5306019650104427`*^9}},
 CellLabel->"In[8]:="],

Cell[BoxData[
 RowBox[{
  RowBox[{"fn", "=", 
   RowBox[{"Function", "[", 
    RowBox[{
     RowBox[{"{", "x", "}"}], ",", "\[IndentingNewLine]", 
     RowBox[{"Block", "[", 
      RowBox[{
       RowBox[{"{", 
        RowBox[{
         RowBox[{"sum", "=", "1.0"}], ",", 
         RowBox[{"inc", "=", "1.0"}]}], "}"}], ",", 
       RowBox[{
        RowBox[{"Do", "[", 
         RowBox[{
          RowBox[{
           RowBox[{"inc", "=", 
            RowBox[{"inc", "*", 
             RowBox[{"x", "/", "i"}]}]}], ";", 
           RowBox[{"sum", "=", 
            RowBox[{"sum", "+", "inc"}]}]}], ",", 
          RowBox[{"{", 
           RowBox[{"i", ",", "10000"}], "}"}]}], "]"}], ";", "sum"}]}], 
      "]"}]}], "]"}]}], ";"}]], "Input",
 CellChangeTimes->{{3.530601601924138*^9, 3.5306016063005753`*^9}, {
  3.5306020567846193`*^9, 3.5306020568476257`*^9}},
 CellLabel->"In[9]:="],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"Map", "[", 
    RowBox[{"fn", ",", "arg"}], "]"}], ";"}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.5306016124351892`*^9, 3.530601627939739*^9}, {
  3.5306020681827593`*^9, 3.530602068230764*^9}},
 CellLabel->"In[10]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"21.5597528`8.785188770501795", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{3.5306021163715773`*^9, 3.5306021825368357`*^9, 
  3.5306061533167114`*^9, 3.5306114160661483`*^9},
 CellLabel->"Out[10]="]
}, Open  ]],

Cell[TextData[{
 "Using ",
 StyleBox["Compile", "Program",
  FontSize->13],
 " instead of ",
 StyleBox[ButtonBox["Function",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Function.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Function.html"], 
  "FunctionLink"],
 " makes the execution over 10 times faster."
}], "Text",
 CellChangeTimes->{{3.5305144438105097`*^9, 3.530514483691497*^9}, {
  3.530523305907817*^9, 3.5305233223120975`*^9}, {3.53167424819761*^9, 
  3.5316742506753397`*^9}, {3.531747707697905*^9, 3.531747713345668*^9}}],

Cell[BoxData[
 RowBox[{
  RowBox[{"cfn", "=", 
   RowBox[{"Compile", "[", 
    RowBox[{
     RowBox[{"{", "x", "}"}], ",", "\[IndentingNewLine]", 
     RowBox[{"Block", "[", 
      RowBox[{
       RowBox[{"{", 
        RowBox[{
         RowBox[{"sum", "=", "1.0"}], ",", 
         RowBox[{"inc", "=", "1.0"}]}], "}"}], ",", 
       RowBox[{
        RowBox[{"Do", "[", 
         RowBox[{
          RowBox[{
           RowBox[{"inc", "=", 
            RowBox[{"inc", "*", 
             RowBox[{"x", "/", "i"}]}]}], ";", 
           RowBox[{"sum", "=", 
            RowBox[{"sum", "+", "inc"}]}]}], ",", 
          RowBox[{"{", 
           RowBox[{"i", ",", "10000"}], "}"}]}], "]"}], ";", "sum"}]}], 
      "]"}]}], "]"}]}], ";"}]], "Input",
 CellChangeTimes->{{3.530601601924138*^9, 3.5306016063005753`*^9}, {
  3.530601683279273*^9, 3.5306016941923637`*^9}, {3.530602090240965*^9, 
  3.530602090352976*^9}},
 CellLabel->"In[11]:="],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"Map", "[", 
    RowBox[{"cfn", ",", "arg"}], "]"}], ";"}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.5306016124351892`*^9, 3.530601627939739*^9}, 
   3.530601720928037*^9, {3.5306020928002205`*^9, 3.530602093264267*^9}},
 CellLabel->"In[12]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"0.2652068`6.875129648841886", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{{3.5306021170736475`*^9, 3.5306021345964003`*^9}, 
   3.5306061651213865`*^9, 3.530611421120678*^9},
 CellLabel->"Out[12]="]
}, Open  ]],

Cell[TextData[{
 "But we can go further by giving ",
 StyleBox["Compile", "FunctionLink",
  FontColor->GrayLevel[0]],
 " some hints about the parallelizable nature of the code, getting an even \
better result."
}], "Text",
 CellChangeTimes->{{3.527777120477315*^9, 3.527777171614205*^9}, {
  3.5305144892520533`*^9, 3.530514490196148*^9}, {3.5316743837132587`*^9, 
  3.531674400120215*^9}, {3.5321897668806562`*^9, 3.532189768527027*^9}}],

Cell[BoxData[
 RowBox[{
  RowBox[{"cfn2", "=", 
   RowBox[{"Compile", "[", 
    RowBox[{
     RowBox[{"{", "x", "}"}], ",", "\[IndentingNewLine]", 
     RowBox[{"Block", "[", 
      RowBox[{
       RowBox[{"{", 
        RowBox[{
         RowBox[{"sum", "=", "1.0"}], ",", 
         RowBox[{"inc", "=", "1.0"}]}], "}"}], ",", 
       RowBox[{
        RowBox[{"Do", "[", 
         RowBox[{
          RowBox[{
           RowBox[{"inc", "=", 
            RowBox[{"inc", "*", 
             RowBox[{"x", "/", "i"}]}]}], ";", 
           RowBox[{"sum", "=", 
            RowBox[{"sum", "+", "inc"}]}]}], ",", 
          RowBox[{"{", 
           RowBox[{"i", ",", "10000"}], "}"}]}], "]"}], ";", "sum"}]}], "]"}],
      ",", "\[IndentingNewLine]", 
     RowBox[{"RuntimeAttributes", "\[Rule]", 
      RowBox[{"{", "Listable", "}"}]}], ",", 
     RowBox[{"Parallelization", "\[Rule]", "True"}]}], "]"}]}], 
  ";"}]], "Input",
 CellChangeTimes->{{3.5306017032802725`*^9, 3.53060171325727*^9}, 
   3.5306018953774805`*^9, {3.5306021060505457`*^9, 3.5306021137383146`*^9}},
 CellLabel->"In[13]:="],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"cfn2", "[", "arg", "]"}], ";"}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.5306016124351892`*^9, 3.530601627939739*^9}, {
   3.530601720928037*^9, 3.530601741881132*^9}, 3.5306021180897493`*^9},
 CellLabel->"In[14]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"0.1404036`6.598923236902939", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{{3.5306021275436945`*^9, 3.530602136749615*^9}, {
   3.5306061710907283`*^9, 3.5306061889297485`*^9}, 3.5306114352546406`*^9},
 CellLabel->"Out[14]="]
}, Open  ]],

Cell[TextData[{
 "On my dual-core machine I get a result 150 times faster than the original; \
the benefit would be even greater with more cores.\n\nBe aware though that \
many ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " functions like ",
 StyleBox[ButtonBox["Table",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Table.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Table.html"], 
  "FunctionLink"],
 ", ",
 StyleBox[ButtonBox["Plot",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Plot.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Plot.html"], 
  "FunctionLink"],
 ", ",
 Cell[BoxData[
  FormBox[
   StyleBox[
    ButtonBox["NIntegrate",
     BaseStyle->"Hyperlink",
     ButtonData->{
       URL["http://reference.wolfram.com/mathematica/ref/NIntegrate.html"], 
       None},
     ButtonNote->
      "http://reference.wolfram.com/mathematica/ref/NIntegrate.html"], 
    "FunctionLink"], TraditionalForm]]],
 ", and so on automatically compile their arguments, so you won\
\[CloseCurlyQuote]t see any improvement when passing them compiled versions \
of your code."
}], "Text",
 CellChangeTimes->{{3.527777212236676*^9, 3.527777227087902*^9}, {
  3.5303597859952183`*^9, 3.5303598085684576`*^9}, {3.5305145169098186`*^9, 
  3.530514517252853*^9}, {3.5306021942008357`*^9, 3.530602195375836*^9}, {
  3.5306024188518357`*^9, 3.530602525372836*^9}, {3.5306122110233383`*^9, 
  3.5306122111325407`*^9}, {3.5316744746702957`*^9, 3.531674558539873*^9}, {
  3.5316746028262177`*^9, 3.531674638336638*^9}, {3.531743017968853*^9, 
  3.531743027400189*^9}}]
}, Open  ]],

Cell[CellGroupData[{

Cell[TextData[{
 "2.5. ...and use ",
 StyleBox["Compile", "Program",
  FontFamily->"Courier"],
 " to generate C code."
}], "Section",
 CellChangeTimes->{{3.5184328635503216`*^9, 3.518432872207187*^9}, {
   3.5184330767446384`*^9, 3.5184330886728315`*^9}, {3.5277751787213044`*^9, 
   3.52777518171651*^9}, {3.5303593967735343`*^9, 3.530359397085535*^9}, 
   3.531674663799675*^9, {3.532194643604498*^9, 3.532194643860396*^9}}],

Cell[TextData[{
 "Furthermore, if your code is compilable, then you can also use the option \
",
 StyleBox[ButtonBox["CompilationTarget",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/CompilationTarget.html"]\
, None},
  ButtonNote->
   "http://reference.wolfram.com/mathematica/ref/CompilationTarget.html"], 
  "FunctionLink"],
 StyleBox[ButtonBox["->\[CloseCurlyDoubleQuote]",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/CompilationTarget.html"]\
, None},
  ButtonNote->
   "http://reference.wolfram.com/mathematica/ref/CompilationTarget.html"],
  FontColor->GrayLevel[0]],
 StyleBox[ButtonBox["C",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/CompilationTarget.html"]\
, None},
  ButtonNote->
   "http://reference.wolfram.com/mathematica/ref/CompilationTarget.html"], 
  "Program",
  FontSize->13,
  FontColor->GrayLevel[0]],
 StyleBox[ButtonBox["\[CloseCurlyDoubleQuote]",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/CompilationTarget.html"]\
, None},
  ButtonNote->
   "http://reference.wolfram.com/mathematica/ref/CompilationTarget.html"],
  FontColor->GrayLevel[0]],
 " to generate C code, call your C compiler to compile it to a DLL, and link \
the DLL back into ",
 StyleBox["Mathematica,",
  FontSlant->"Italic"],
 " all automatically. There is more overhead in the compilation stage, but \
the DLL runs directly on your CPU, not on the ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " virtual machine, so the results can be even faster."
}], "Text",
 CellChangeTimes->{{3.518433092625227*^9, 3.518433157435707*^9}, {
   3.527777326085676*^9, 3.527777357520732*^9}, {3.527777433882866*^9, 
   3.527777494800973*^9}, {3.530340742377612*^9, 3.5303407499436255`*^9}, {
   3.530359820455679*^9, 3.530359836726507*^9}, {3.5305145300231295`*^9, 
   3.530514565070949*^9}, {3.5305233521240587`*^9, 3.530523352125059*^9}, 
   3.5316747068385057`*^9, {3.5316754129120083`*^9, 3.5316754774267406`*^9}, {
   3.5317478097507563`*^9, 3.53174782629408*^9}}],

Cell[BoxData[
 RowBox[{
  RowBox[{"cfn2C", "=", 
   RowBox[{"Compile", "[", 
    RowBox[{
     RowBox[{"{", "x", "}"}], ",", "\[IndentingNewLine]", 
     RowBox[{"Block", "[", 
      RowBox[{
       RowBox[{"{", 
        RowBox[{
         RowBox[{"sum", "=", "1.0"}], ",", 
         RowBox[{"inc", "=", "1.0"}]}], "}"}], ",", 
       RowBox[{
        RowBox[{"Do", "[", 
         RowBox[{
          RowBox[{
           RowBox[{"inc", "=", 
            RowBox[{"inc", "*", 
             RowBox[{"x", "/", "i"}]}]}], ";", 
           RowBox[{"sum", "=", 
            RowBox[{"sum", "+", "inc"}]}]}], ",", 
          RowBox[{"{", 
           RowBox[{"i", ",", "10000"}], "}"}]}], "]"}], ";", "sum"}]}], "]"}],
      ",", "\[IndentingNewLine]", 
     RowBox[{"RuntimeAttributes", "\[Rule]", 
      RowBox[{"{", "Listable", "}"}]}], ",", 
     RowBox[{"Parallelization", "\[Rule]", "True"}], ",", 
     RowBox[{"CompilationTarget", "\[Rule]", "\"\<C\>\""}]}], "]"}]}], 
  ";"}]], "Input",
 CellChangeTimes->{{3.5306017032802725`*^9, 3.53060171325727*^9}, 
   3.5306018953774805`*^9, {3.5306021060505457`*^9, 3.5306021137383146`*^9}, {
   3.530605439157422*^9, 3.53060544765915*^9}},
 CellLabel->"In[15]:="],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"cfn2C", "[", "arg", "]"}], ";"}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.5306016124351892`*^9, 3.530601627939739*^9}, {
   3.530601720928037*^9, 3.530601741881132*^9}, 3.5306021180897493`*^9, 
   3.530605449343896*^9},
 CellLabel->"In[16]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"0.0470015`5.882932884455993", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{3.5306061998913755`*^9},
 CellLabel->"Out[16]="]
}, Open  ]]
}, Open  ]],

Cell[CellGroupData[{

Cell["3. Use built-in functions.", "Section",
 CellChangeTimes->{{3.5184328635503216`*^9, 3.518432872207187*^9}, {
   3.5184330767446384`*^9, 3.5184330886728315`*^9}, {3.5184331625812216`*^9, 
   3.5184331685798216`*^9}, {3.51843359260822*^9, 3.5184336015751166`*^9}, 
   3.5184339650794635`*^9, {3.5184339985448093`*^9, 3.518434010359991*^9}, 
   3.518437409746896*^9, {3.5277749472450976`*^9, 3.5277749545459104`*^9}, {
   3.52787108199835*^9, 3.52787108658235*^9}, {3.5303460271309757`*^9, 
   3.530346028035777*^9}, {3.5303582888429885`*^9, 3.530358288998989*^9}, 
   3.5303594077871537`*^9, 3.53052482310856*^9, 3.531675532835513*^9, {
   3.532194646860272*^9, 3.532194647140368*^9}}],

Cell[TextData[{
 StyleBox["Mathematica ",
  FontSlant->"Italic"],
 "has a lot of functions. More than the average person would care to sit down \
and learn in one go. So it is not surprising that I often see code where \
someone has implemented some operation without having realized that ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " already knows how to do it. Not only is it a waste of time re-implementing \
work that is already done, but our guys are paid to worry about what the best \
algorithms are for different kinds of input and how to implement them \
efficiently, so most built-in functions are really fast.\n\nIf you find \
something close-but-not-quite-right, then check the options and optional \
arguments; often they generalize functions to cover many specialized uses or \
abstracted applications.\n\nHere is such an example. If I have a list of a \
million 2\[Times]2 matrices that I want to turn into a list of a million flat \
lists of 4 elements, the conceptually easiest way might be to ",
 StyleBox[ButtonBox["Map",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Map.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Map.html"], 
  "FunctionLink"],
 " the basic ",
 StyleBox[ButtonBox["Flatten",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Flatten.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Flatten.html"], 
  "FunctionLink"],
 " operation down the list of them. "
}], "Text",
 CellChangeTimes->{{3.518434014112366*^9, 3.5184343798639374`*^9}, {
   3.518434581178067*^9, 3.518434622979247*^9}, {3.5243701602579975`*^9, 
   3.5243702648717813`*^9}, {3.5243798220323095`*^9, 3.524380014552248*^9}, {
   3.5278780336779966`*^9, 3.527878291211747*^9}, {3.5278783302066464`*^9, 
   3.5278783990915346`*^9}, {3.5303459468688345`*^9, 
   3.5303460231685686`*^9}, {3.530357710671773*^9, 3.530357801151932*^9}, {
   3.5303578399023995`*^9, 3.530357914657731*^9}, {3.530358088910037*^9, 
   3.5303581120604777`*^9}, 3.5303582189830656`*^9, 3.530360106218981*^9, {
   3.5303601362646337`*^9, 3.5303601547974663`*^9}, {3.530360190802329*^9, 
   3.5303602018637486`*^9}, {3.530514724445949*^9, 3.530514724933949*^9}, {
   3.5305217752385635`*^9, 3.53052178047661*^9}, {3.530523496674963*^9, 
   3.530523511080844*^9}, {3.5305244410357056`*^9, 3.5305244432669287`*^9}, {
   3.5316755433121157`*^9, 3.531675561040298*^9}, 3.531675862400221*^9, {
   3.531844205831636*^9, 3.531844206599337*^9}}],

Cell[BoxData[
 RowBox[{
  RowBox[{"data", "=", 
   RowBox[{"RandomReal", "[", 
    RowBox[{"1", ",", 
     RowBox[{"{", 
      RowBox[{"1000000", ",", "2", ",", "2"}], "}"}]}], "]"}]}], 
  ";"}]], "Input",
 CellChangeTimes->{{3.5303575927979655`*^9, 3.530357660533285*^9}},
 CellLabel->"In[17]:="],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"Map", "[", 
    RowBox[{"Flatten", ",", "data"}], "]"}], ";"}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.5303575812851458`*^9, 3.5303575888043585`*^9}, {
  3.5303576437788553`*^9, 3.53035765187527*^9}},
 CellLabel->"In[18]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"0.2652068`6.875129648841886", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{
  3.5303575891943593`*^9, {3.53035765232767*^9, 3.5303576656812935`*^9}, 
   3.530611470281145*^9},
 CellLabel->"Out[18]="]
}, Open  ]],

Cell[TextData[{
 "But ",
 StyleBox["Flatten", "Program",
  FontSize->13],
 " knows how to do this whole task on its own when you specify that levels 2 \
and 3 of the data structure should be merged and level 1 be left alone. \
Specifying such details might be comparatively fiddly, but staying within ",
 StyleBox["Flatten", "FunctionLink",
  FontColor->GrayLevel[0]],
 " to do the whole flattening job turns out to be nearly 4 times faster than \
re-implementing that sub-feature yourself."
}], "Text",
 CellChangeTimes->{{3.530357917933737*^9, 3.5303580676784*^9}, {
   3.530360216262574*^9, 3.530360262454255*^9}, {3.530521798464207*^9, 
   3.530521812256965*^9}, {3.530523528493325*^9, 3.5305235284943256`*^9}, 
   3.530524445498152*^9, {3.5317478672686663`*^9, 3.531747870724441*^9}}],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"Flatten", "[", 
    RowBox[{"data", ",", 
     RowBox[{"{", 
      RowBox[{
       RowBox[{"{", "1", "}"}], ",", 
       RowBox[{"{", 
        RowBox[{"2", ",", "3"}], "}"}]}], "}"}]}], "]"}], ";"}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.530357432148884*^9, 3.53035757267393*^9}, {
  3.5303576244504213`*^9, 3.530357634060038*^9}},
 CellLabel->"In[19]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"0.078002`6.343650731799633", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{{3.530357454410123*^9, 3.5303575730639315`*^9}, {
   3.530357634652839*^9, 3.5303576632476892`*^9}, 3.5306114729332128`*^9},
 CellLabel->"Out[19]="]
}, Open  ]],

Cell["\<\
 So remember\[LongDash]do a search in the Help menu before you implement \
anything.\
\>", "Text",
 CellChangeTimes->{{3.5303582209642687`*^9, 3.5303582326798897`*^9}, {
  3.530521821522818*^9, 3.5305218236102357`*^9}, {3.531675839302396*^9, 
  3.531675850582405*^9}}]
}, Open  ]],

Cell[CellGroupData[{

Cell[TextData[{
 "4. Use Wolfram ",
 StyleBox["Workbench.",
  FontSlant->"Italic"]
}], "Section",
 CellChangeTimes->{{3.5184328635503216`*^9, 3.518432872207187*^9}, {
   3.5184330767446384`*^9, 3.5184330886728315`*^9}, {3.5184331625812216`*^9, 
   3.5184331685798216`*^9}, {3.51843359260822*^9, 3.5184336015751166`*^9}, 
   3.5184339650794635`*^9, {3.5184339985448093`*^9, 3.518434010359991*^9}, {
   3.5184344107140226`*^9, 3.5184344162735786`*^9}, {3.518434642964245*^9, 
   3.5184346525882072`*^9}, 3.5184356995218906`*^9, 3.5303594030603456`*^9, {
   3.5305233681152563`*^9, 3.5305233716189566`*^9}, {3.53052482626756*^9, 
   3.5305248263955603`*^9}, 3.531675879039959*^9, {3.532194649940309*^9, 
   3.532194650260353*^9}}],

Cell[TextData[{
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " can be quite forgiving of some kinds of programming mistakes\[LongDash]it \
will proceed happily in symbolic mode if you forget to initialize a variable \
at the right point and doesn\[CloseCurlyQuote]t care about recursion or \
unexpected data types. That\[CloseCurlyQuote]s great when you just need to \
get a quick answer, but it will also let you get away with less than optimal \
solutions without realizing it. \n\n",
 StyleBox[ButtonBox["Workbench",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://www.wolfram.com/products/workbench/"], None},
  ButtonNote->"http://www.wolfram.com/products/workbench/"],
  FontSlant->"Italic"],
 " helps in several ways. First it lets you debug and organize large code \
projects better, and having clean, organized code should make it easier to \
write good code. But the key feature in this context is the profiler that \
lets you see which lines of code used up the time, and how many times they \
were called.\n\nTake this example, a truly horrible way (computationally \
speaking) to implement ",
 StyleBox[ButtonBox["Fibonacci",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Fibonacci.html"], None},
  
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Fibonacci.html"], 
  "FunctionLink"],
 " numbers. If you didn\[CloseCurlyQuote]t think about the consequences of \
the double recursion, you might be surprised by the 22 seconds it takes to \
evaluate ",
 StyleBox["fib[35]", "FunctionLink",
  FontColor->GrayLevel[0]],
 " (about the same time it takes the built-in function to calculate all \
208,987,639 digits of ",
 StyleBox["Fibonacci[", "Program",
  FontSize->13],
 StyleBox["1000000000]", "Program",
  FontSize->13,
  FontColor->GrayLevel[0]],
 " [see tip 3])."
}], "Text",
 CellChangeTimes->{{3.5184346553404827`*^9, 3.5184349880267477`*^9}, {
   3.5243700356293783`*^9, 3.524370138386759*^9}, {3.527777512897004*^9, 
   3.5277776468076396`*^9}, {3.5277784575798283`*^9, 3.527778477189063*^9}, {
   3.52787098652035*^9, 3.5278710025743504`*^9}, {3.530340802125717*^9, 
   3.530340832420971*^9}, {3.53035879086847*^9, 3.530358991609623*^9}, {
   3.530359448050824*^9, 3.530359448378425*^9}, {3.530359870531767*^9, 
   3.530359913401642*^9}, 3.5303600660479097`*^9, {3.530523396650962*^9, 
   3.530523426082847*^9}, {3.5305234605467386`*^9, 3.530523465538737*^9}, {
   3.530524424203023*^9, 3.530524435531155*^9}, 3.53052483691356*^9, 
   3.530611519157198*^9, {3.531675890293474*^9, 3.531675899367023*^9}, 
   3.531675993480646*^9, {3.53167604454745*^9, 3.531676044768195*^9}, {
   3.531676671297133*^9, 3.531676683688246*^9}, {3.531748051119424*^9, 
   3.531748099238312*^9}, 3.5321897024672832`*^9, {3.532189800415896*^9, 
   3.5321898047183332`*^9}}],

Cell[CellGroupData[{

Cell[BoxData[{
 RowBox[{
  RowBox[{
   RowBox[{"fib", "[", "n_", "]"}], ":=", 
   RowBox[{
    RowBox[{"fib", "[", 
     RowBox[{"n", "-", "1"}], "]"}], "+", 
    RowBox[{"fib", "[", 
     RowBox[{"n", "-", "2"}], "]"}]}]}], ";"}], "\n", 
 RowBox[{
  RowBox[{
   RowBox[{"fib", "[", "1", "]"}], "=", "1"}], ";"}], "\[IndentingNewLine]", 
 RowBox[{
  RowBox[{
   RowBox[{"fib", "[", "2", "]"}], "=", "1"}], ";"}], "\[IndentingNewLine]", 
 RowBox[{
  RowBox[{
   RowBox[{"fib", "[", "35", "]"}], ";"}], "//", "AbsoluteTiming"}]}], "Input",\

 CellChangeTimes->{{3.52777924924942*^9, 3.527779265240448*^9}, {
   3.527779371102234*^9, 3.527779385345059*^9}, 3.5277795004928617`*^9, {
   3.5277795984620333`*^9, 3.5277796119716573`*^9}, {3.530519723846079*^9, 
   3.530519730908785*^9}},
 CellLabel->"In[20]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"22.3709736`8.80122987879539", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{3.5303600560326924`*^9, 3.5306115116846066`*^9},
 CellLabel->"Out[23]="]
}, Open  ]],

Cell[TextData[{
 "Running the code in the profiler reveals the reason. The main rule is \
invoked 9,227,464 times, and the ",
 StyleBox["fib[1]", "Program"],
 " value is requested 18,454,929 times. \n\nBeing told what your code really \
does, rather than what you thought it would do, can be a real eye-opener."
}], "Text",
 CellChangeTimes->{{3.5303589994720364`*^9, 3.5303590234960785`*^9}, {
  3.530359095880206*^9, 3.530359122899453*^9}, {3.5305146837519493`*^9, 
  3.530514700326949*^9}, {3.5305218810197153`*^9, 3.530521881179747*^9}, {
  3.5316768827508507`*^9, 3.531676887716514*^9}}]
}, Open  ]],

Cell[CellGroupData[{

Cell["5. Remember values that you will need in the future.", "Section",
 CellChangeTimes->{{3.5184328635503216`*^9, 3.518432872207187*^9}, {
   3.5184330767446384`*^9, 3.5184330886728315`*^9}, {3.5184331625812216`*^9, 
   3.5184331685798216`*^9}, {3.51843359260822*^9, 3.5184336015751166`*^9}, 
   3.5184339650794635`*^9, {3.5184339985448093`*^9, 3.518434010359991*^9}, {
   3.5184344107140226`*^9, 3.5184344162735786`*^9}, {3.518434642964245*^9, 
   3.5184346525882072`*^9}, 3.5184352176447077`*^9, {3.5184352961035523`*^9, 
   3.5184353023281746`*^9}, 3.5184357016731052`*^9, 3.518437411243045*^9, 
   3.530359412513962*^9, {3.5316769500052443`*^9, 3.531676952561431*^9}, {
   3.5321946543323174`*^9, 3.5321946546200123`*^9}}],

Cell[TextData[{
 "This is good programming advice in any language. The ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " construct that you will want to know is this: "
}], "Text",
 CellChangeTimes->{{3.5184353165765996`*^9, 3.518435349513893*^9}, {
  3.5243729675803022`*^9, 3.5243729806531253`*^9}, {3.524373633030671*^9, 
  3.5243736686455336`*^9}, {3.530340912980512*^9, 3.5303409342121496`*^9}, {
  3.5316769368044147`*^9, 3.531676937842472*^9}}],

Cell[BoxData[
 RowBox[{
  RowBox[{"f", "[", "x_", "]"}], ":=", 
  RowBox[{
   RowBox[{"f", "[", "x", "]"}], "=", 
   RowBox[{"(*", 
    RowBox[{"What", " ", "the", " ", "function", " ", "does"}], 
    "*)"}]}]}]], "Input",
 CellChangeTimes->{{3.5184353522781696`*^9, 3.5184353964935904`*^9}, {
   3.5303409417937627`*^9, 3.530340943572166*^9}, 3.532189855752719*^9}],

Cell[TextData[{
 "It saves the result of calling ",
 StyleBox["f", "Program"],
 " on any value, so that if it is called again on the same value, ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " will not need to work it out again. You are trading speed for memory here, \
so it isn\[CloseCurlyQuote]t appropriate if your function is likely to be \
called for a huge number of values, but rarely the same ones twice. But if \
the possible input set is constrained, this can really help. Here it is \
rescuing the program that I used to illustrate tip 3. Change the first rule \
to this:"
}], "Text",
 CellChangeTimes->{{3.5184353165765996`*^9, 3.518435472615202*^9}, {
   3.527778935029668*^9, 3.5277790242024245`*^9}, {3.527779096524152*^9, 
   3.527779115852586*^9}, {3.527779325128953*^9, 3.5277793547690053`*^9}, {
   3.527779435251547*^9, 3.527779479088624*^9}, {3.5277796736083655`*^9, 
   3.5277796827967815`*^9}, {3.52787105300035*^9, 3.52787106428935*^9}, {
   3.530341107512854*^9, 3.53034118495339*^9}, {3.530341220973853*^9, 
   3.530341258413919*^9}, {3.5303412922659783`*^9, 3.530341330361245*^9}, {
   3.53035917785835*^9, 3.530359236639253*^9}, {3.530359459329644*^9, 
   3.5303594594700446`*^9}, {3.530521961495807*^9, 3.530521972128933*^9}, 
   3.5305244507226744`*^9, {3.531677475540741*^9, 3.531677517727303*^9}, {
   3.531743071628285*^9, 3.531743072704618*^9}}],

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"fib", "[", "n_", "]"}], ":=", 
   RowBox[{
    RowBox[{"fib", "[", "n", "]"}], "=", 
    RowBox[{
     RowBox[{"fib", "[", 
      RowBox[{"n", "-", "1"}], "]"}], "+", 
     RowBox[{"fib", "[", 
      RowBox[{"n", "-", "2"}], "]"}]}]}]}], ";"}]], "Input",
 CellChangeTimes->{{3.5277788789163694`*^9, 3.5277788808039722`*^9}, {
   3.5277789223780456`*^9, 3.527778922440446*^9}, 3.527779032626439*^9, {
   3.527779511444081*^9, 3.5277795152660875`*^9}, {3.5303603029831266`*^9, 
   3.530360306976733*^9}}],

Cell[TextData[{
 "And it becomes immeasurably fast, since ",
 StyleBox["fib[35]", "Program"],
 " now only requires the main rule to be evaluated 33 times. Looking up \
previous results prevents the need to repeatedly recurse down to ",
 StyleBox["fib[1]", "Program"],
 "."
}], "Text",
 CellChangeTimes->{{3.530359245640469*^9, 3.530359336697829*^9}, {
   3.5303603139499454`*^9, 3.530360315431948*^9}, {3.5305219992911673`*^9, 
   3.530522001779416*^9}, 3.5305244533859406`*^9, {3.531677544672453*^9, 
   3.531677546398597*^9}}]
}, Open  ]],

Cell[CellGroupData[{

Cell["6. Parallelize.", "Section",
 CellChangeTimes->{{3.5184328635503216`*^9, 3.518432872207187*^9}, {
   3.5184330767446384`*^9, 3.5184330886728315`*^9}, {3.5184331625812216`*^9, 
   3.5184331685798216`*^9}, 3.5184357047054086`*^9, 3.5303594140271645`*^9, 
   3.53167756333573*^9, {3.532194657980077*^9, 3.532194658340001*^9}}],

Cell[TextData[{
 "An increasing number of ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " operations will automatically parallelize over local cores (most linear \
algebra, image processing, and statistics), and, as we have seen, so does ",
 StyleBox["Compile", "Program",
  FontSize->13],
 " if manually requested. But for other operations, or if you want to \
parallelize over remote hardware, you can use the built-in parallel \
programming constructs.\n\nThere is a collection of tools for this, but for \
very independent tasks, you can get quite a long way with just ",
 StyleBox[ButtonBox["ParallelTable",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/ParallelTable.html"], 
    None},
  ButtonNote->
   "http://reference.wolfram.com/mathematica/ref/ParallelTable.html"], 
  "FunctionLink"],
 ", ",
 StyleBox[ButtonBox["ParallelMap",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/ParallelMap.html"], 
    None},
  ButtonNote->
   "http://reference.wolfram.com/mathematica/ref/ParallelMap.html"], 
  "FunctionLink"],
 ", and ",
 StyleBox[ButtonBox["ParallelTry",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/ParallelTry.html"], 
    None},
  ButtonNote->
   "http://reference.wolfram.com/mathematica/ref/ParallelTry.html"], 
  "FunctionLink"],
 ". Each of these automatically takes care of communication, worker \
management, and collection of results. There is some overhead for sending the \
task and retrieving the result, so there is a trade-off of time gained versus \
time lost. Your ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " comes with four compute kernels, and you can scale up with ",
 Cell[BoxData[
  FormBox[
   ButtonBox[
    StyleBox[
     RowBox[{"grid", 
      StyleBox[
       AdjustmentBox["Mathematica",
        BoxMargins->{{-0.175, 0}, {0, 0}}],
       FontSlant->"Italic"]}]],
    BaseStyle->"Hyperlink",
    ButtonData->{
      URL["http://www.wolfram.com/gridmathematica/"], None},
    ButtonNote->"http://www.wolfram.com/gridmathematica/"], TextForm]]],
 " if you have access to additional CPU power. Here, ",
 StyleBox["ParallelTable", "Program",
  FontSize->13],
 " gives me double the performance, since it is running on my dual-core \
machine. More CPUs would give a better speedup."
}], "Text",
 CellChangeTimes->{{3.518433176332597*^9, 3.5184331922131844`*^9}, {
   3.518433226046568*^9, 3.5184334944344034`*^9}, {3.524373024239602*^9, 
   3.524373192454697*^9}, {3.52787122979035*^9, 3.52787126131735*^9}, 
   3.530341425584813*^9, {3.530360348628806*^9, 3.5303604619786053`*^9}, {
   3.5303604934292607`*^9, 3.5303605518669634`*^9}, {3.530522023148553*^9, 
   3.530522094615699*^9}, {3.530523569557536*^9, 3.530523646549932*^9}, {
   3.5305244691415157`*^9, 3.530524476598262*^9}, {3.530524528304432*^9, 
   3.5305245362752285`*^9}, {3.531677619814473*^9, 3.531677646530725*^9}, 
   3.531677676580605*^9, 3.5316777107945967`*^9, {3.531678816447279*^9, 
   3.531678876434552*^9}, {3.531748162780654*^9, 3.5317481711386147`*^9}, {
   3.531748201910081*^9, 3.531748266921167*^9}}],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"Table", "[", 
    RowBox[{
     RowBox[{"PrimeQ", "[", "x", "]"}], ",", 
     RowBox[{"{", 
      RowBox[{"x", ",", 
       RowBox[{"10", "^", "1000"}], ",", 
       RowBox[{
        RowBox[{"10", "^", "1000"}], "+", "5000"}]}], "}"}]}], "]"}], ";"}], "//",
   "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.5243732121575317`*^9, 3.524373343275762*^9}, {
  3.5243734449099407`*^9, 3.5243735703965607`*^9}},
 CellLabel->"In[24]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"8.8298264`8.397497158651891", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{{3.5243732967252803`*^9, 3.524373343868563*^9}, {
   3.524373447140744*^9, 3.524373549102524*^9}, 3.5243735809265795`*^9, 
   3.5306115423081913`*^9},
 CellLabel->"Out[24]="]
}, Open  ]],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"ParallelTable", "[", 
    RowBox[{
     RowBox[{"PrimeQ", "[", "x", "]"}], ",", 
     RowBox[{"{", 
      RowBox[{"x", ",", 
       RowBox[{"10", "^", "1000"}], ",", 
       RowBox[{
        RowBox[{"10", "^", "1000"}], "+", "5000"}]}], "}"}]}], "]"}], ";"}], "//",
   "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.524373555576535*^9, 3.524373577010973*^9}},
 CellLabel->"In[25]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"4.992128`8.149830705783524", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{{3.5243735603501434`*^9, 3.52437358682339*^9}, {
  3.5306115497495823`*^9, 3.5306115770190816`*^9}},
 CellLabel->"Out[25]="]
}, Open  ]],

Cell[TextData[{
 "Anything that ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " can do, it can also do in parallel. For example, you could send a set of \
parallel tasks to remote hardware, each of which compiles and runs in C or on \
a GPU."
}], "Text",
 CellChangeTimes->{{3.5278712720849*^9, 3.527871382783969*^9}, {
  3.5317430969336863`*^9, 3.5317430978538513`*^9}}]
}, Open  ]],

Cell[CellGroupData[{

Cell[TextData[{
 "6.5. Think about ",
 StyleBox["CUDALink",
  FontSlant->"Italic"],
 " and ",
 StyleBox["OpenCLLink.",
  FontSlant->"Italic"]
}], "Section",
 CellChangeTimes->{{3.5184328635503216`*^9, 3.518432872207187*^9}, {
   3.5184330767446384`*^9, 3.5184330886728315`*^9}, {3.5184331625812216`*^9, 
   3.5184331685798216`*^9}, {3.51843359260822*^9, 3.5184336015751166`*^9}, 
   3.5184339650794635`*^9, {3.5184339985448093`*^9, 3.518434010359991*^9}, {
   3.5184344107140226`*^9, 3.5184344162735786`*^9}, 3.5184357087058086`*^9, {
   3.5184376952224407`*^9, 3.518437715879506*^9}, {3.5277750279908395`*^9, 
   3.52777502831844*^9}, 3.530357255416173*^9, 3.530359419845975*^9, 
   3.5317484703545103`*^9, 3.532194661676175*^9}],

Cell[TextData[{
 "If you have GPU hardware, there are some really fast things you can do with \
massive parallelization. Unless one of the built-in CUDA-optimized functions \
happens to do what you want, you will need to do a little work, but the ",
 StyleBox[ButtonBox["CUDALink",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/CUDALink/guide/CUDALink.\
html"], None},
  ButtonNote->
   "http://reference.wolfram.com/mathematica/CUDALink/guide/CUDALink.html"],
  FontSlant->"Italic"],
 " and ",
 StyleBox[ButtonBox["OpenCLLink",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/OpenCLLink/tutorial/\
Overview.html"], None},
  ButtonNote->
   "http://reference.wolfram.com/mathematica/OpenCLLink/tutorial/Overview.\
html"],
  FontSlant->"Italic"],
 " tools automate a lot of the messy details for you."
}], "Text",
 CellChangeTimes->{{3.5184377188638043`*^9, 3.51843783222814*^9}, {
   3.530357269159797*^9, 3.530357291857837*^9}, {3.5303605979514446`*^9, 
   3.5303606162502766`*^9}, {3.5305221452357597`*^9, 
   3.5305221600902452`*^9}, {3.530523711812379*^9, 3.530523756069953*^9}, 
   3.5316790559816103`*^9, {3.532189952347513*^9, 3.5321899524900312`*^9}, 
   3.532194702674841*^9}]
}, Open  ]],

Cell[CellGroupData[{

Cell[TextData[{
 "7. Use ",
 StyleBox["Sow", "Program"],
 " and ",
 StyleBox["Reap", "Program"],
 " to accumulate large amounts of data (not ",
 StyleBox["AppendTo", "Program"],
 ")."
}], "Section",
 CellChangeTimes->{{3.5184328635503216`*^9, 3.518432872207187*^9}, {
   3.5184330767446384`*^9, 3.5184330886728315`*^9}, {3.5184331625812216`*^9, 
   3.5184331685798216`*^9}, {3.51843359260822*^9, 3.5184336015751166`*^9}, 
   3.5184339650794635`*^9, 3.5184357067776155`*^9, {3.5243737976139603`*^9, 
   3.524373800967966*^9}, {3.527774963952727*^9, 3.5277749888347707`*^9}, 
   3.530359421171977*^9, 3.531679133220194*^9, {3.532194664467731*^9, 
   3.532194664803981*^9}}],

Cell[TextData[{
 "Because of the flexibility of ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " data structures, ",
 StyleBox[ButtonBox["AppendTo",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/AppendTo.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/AppendTo.html"], 
  "FunctionLink"],
 " can\[CloseCurlyQuote]t assume that you will be appending a number, because \
you might equally append a document or a sound or an image. As a result, ",
 StyleBox["AppendTo", "Program",
  FontSize->13],
 " must create a fresh copy of all of the data, restructured to accommodate \
the appended information. This makes it progressively slower as the data \
accumulates. (And the construct ",
 StyleBox["data=Append[data,value] ", "Program"],
 "is the same as ",
 StyleBox["AppendTo", "Program"],
 ".)\n\nInstead use ",
 StyleBox[ButtonBox["Sow",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Sow.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Sow.html"], 
  "FunctionLink"],
 " and ",
 StyleBox[ButtonBox["Reap",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Reap.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Reap.html"], 
  "FunctionLink"],
 ". ",
 StyleBox["Sow", "Program",
  FontSize->13],
 " throws out the values that you want to accumulate, and ",
 StyleBox["Reap", "Program",
  FontSize->13],
 " collects them and builds a data object once at the end. The following are \
equivalent:"
}], "Text",
 CellChangeTimes->{{3.5184336114471035`*^9, 3.518433776014559*^9}, {
   3.518433815240481*^9, 3.5184339594619017`*^9}, {3.5243738166303935`*^9, 
   3.524373898546138*^9}, {3.5277797254160566`*^9, 3.527779816005416*^9}, {
   3.5278714106257524`*^9, 3.527871464643154*^9}, {3.5303606431291237`*^9, 
   3.530360659821153*^9}, {3.530360694952415*^9, 3.530360701754027*^9}, {
   3.5305237793076286`*^9, 3.530523813981161*^9}, {3.5305244834689484`*^9, 
   3.5305244930369053`*^9}, 3.531679158857614*^9, 3.531679205842345*^9, {
   3.5316794108987722`*^9, 3.531679411456296*^9}, {3.5317431373249817`*^9, 
   3.531743138060718*^9}, {3.531743446629601*^9, 3.531743446874591*^9}, {
   3.53174848476062*^9, 3.5317484949278803`*^9}}],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"data", "=", 
    RowBox[{"{", "}"}]}], ";", 
   RowBox[{"Do", "[", 
    RowBox[{
     RowBox[{"AppendTo", "[", 
      RowBox[{"data", ",", 
       RowBox[{"RandomReal", "[", "x", "]"}]}], "]"}], ",", 
     RowBox[{"{", 
      RowBox[{"x", ",", "0", ",", "40000"}], "}"}]}], "]"}], ";"}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.524373834570425*^9, 3.524373855006461*^9}, {
  3.5243739066581516`*^9, 3.5243739529434333`*^9}, {3.52777982410183*^9, 
  3.5277798557854853`*^9}, {3.5303607149984503`*^9, 3.530360719912459*^9}},
 CellLabel->"In[1]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"13.56498`7.583964151276886", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{
  3.5243739542538357`*^9, {3.5277798433366632`*^9, 3.5277798621190968`*^9}, 
   3.5306116085006886`*^9, 3.543415243059738*^9},
 CellLabel->"Out[1]="]
}, Open  ]],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"data", "=", 
    RowBox[{
     RowBox[{"Reap", "[", 
      RowBox[{"Do", "[", 
       RowBox[{
        RowBox[{"Sow", "[", 
         RowBox[{"RandomReal", "[", "x", "]"}], "]"}], ",", 
        RowBox[{"{", 
         RowBox[{"x", ",", "0", ",", "40000"}], "}"}]}], "]"}], "]"}], "[", 
     RowBox[{"[", "2", "]"}], "]"}]}], ";"}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.5243739588090434`*^9, 3.524373991584701*^9}, {
   3.524374037667182*^9, 3.5243740382755833`*^9}, 3.527779831168642*^9, {
   3.527779867282706*^9, 3.527779868577508*^9}, {3.530360723001264*^9, 
   3.530360725965269*^9}},
 CellLabel->"In[27]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"0.1092028`6.489778767477871", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{3.5243739923803024`*^9, 3.5243740431115913`*^9, 
  3.5277798698567104`*^9, 3.5306116097799215`*^9},
 CellLabel->"Out[27]="]
}, Open  ]]
}, Open  ]],

Cell[CellGroupData[{

Cell[TextData[{
 "8. Use ",
 StyleBox["Block", "Program"],
 " or ",
 StyleBox["With", "Program"],
 " rather than ",
 StyleBox["Module.", "Program"]
}], "Section",
 CellChangeTimes->{{3.5184328635503216`*^9, 3.518432872207187*^9}, {
   3.5184330767446384`*^9, 3.5184330886728315`*^9}, {3.5184331625812216`*^9, 
   3.5184331685798216`*^9}, {3.51843359260822*^9, 3.5184336015751166`*^9}, 
   3.5184339650794635`*^9, 3.5184357067776155`*^9, {3.518437281637086*^9, 
   3.5184372932532473`*^9}, 3.518437693239242*^9, {3.527872582324911*^9, 
   3.527872614625141*^9}, 3.5303594262887864`*^9, 3.5316794316481857`*^9, {
   3.532194667787909*^9, 3.5321946680677223`*^9}}],

Cell[TextData[{
 StyleBox[ButtonBox["Block",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Block.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Block.html"], 
  "FunctionLink"],
 ", ",
 StyleBox[ButtonBox["With",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/With.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/With.html"], 
  "FunctionLink"],
 StyleBox[ButtonBox[",",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/With.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/With.html"],
  FontColor->GrayLevel[0]],
 " and ",
 StyleBox[ButtonBox["Module",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Module.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Module.html"], 
  "FunctionLink"],
 " are all localization constructs with slightly different properties. In my \
experience, ",
 StyleBox["Block", "Program"],
 " and ",
 StyleBox[ButtonBox["Module",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Module.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Module.html"], 
  "Program",
  FontColor->GrayLevel[0]],
 " are interchangeable in at least 95% of code that I write, but ",
 StyleBox[ButtonBox["Block",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Block.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Block.html"], 
  "Program",
  FontColor->GrayLevel[0]],
 " is usually faster, and in some cases ",
 StyleBox[ButtonBox["With",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/With.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/With.html"], 
  "Program",
  FontColor->GrayLevel[0]],
 " (effectively ",
 StyleBox[ButtonBox["Block",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Block.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Block.html"], 
  "Program",
  FontColor->GrayLevel[0]],
 " with the variables in a read-only state) is faster still."
}], "Text",
 CellChangeTimes->{{3.518437300237946*^9, 3.518437357447666*^9}, {
   3.5243806647037907`*^9, 3.524380666279393*^9}, {3.5278726173154097`*^9, 
   3.527872785452222*^9}, {3.5278728782995057`*^9, 3.5278728802617016`*^9}, {
   3.530523825668992*^9, 3.5305239185667014`*^9}, 3.5305244961802197`*^9, 
   3.53167951187016*^9, {3.53167957045483*^9, 3.531679620881929*^9}}],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"Do", "[", 
    RowBox[{
     RowBox[{"Module", "[", 
      RowBox[{
       RowBox[{"{", 
        RowBox[{"x", "=", "2."}], "}"}], ",", 
       RowBox[{"1", "/", "x"}]}], "]"}], ",", 
     RowBox[{"{", "1000000", "}"}]}], "]"}], ";"}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.5243805877010555`*^9, 3.5243806423645515`*^9}, {
  3.5278720387095547`*^9, 3.5278720569773817`*^9}, {3.530523923293229*^9, 
  3.530523926092949*^9}},
 CellLabel->"In[28]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"4.1497064`8.069562364094677", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{{3.524380588761857*^9, 3.5243806471225595`*^9}, {
   3.5278720460772915`*^9, 3.527872062311915*^9}, 3.527872809805657*^9, 
   3.530611616924905*^9},
 CellLabel->"Out[28]="]
}, Open  ]],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"Do", "[", 
    RowBox[{
     RowBox[{"Block", "[", 
      RowBox[{
       RowBox[{"{", 
        RowBox[{"x", "=", "2."}], "}"}], ",", 
       RowBox[{"1", "/", "x"}]}], "]"}], ",", 
     RowBox[{"{", "1000000", "}"}]}], "]"}], ";"}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.5278725688375626`*^9, 3.5278725695176306`*^9}, {
  3.5305239275488033`*^9, 3.5305239307644815`*^9}},
 CellLabel->"In[29]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"1.4664376`7.617808581063314", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{3.5278725714598246`*^9, 3.527872802708947*^9, 
  3.530611620294591*^9},
 CellLabel->"Out[29]="]
}, Open  ]]
}, Open  ]],

Cell[CellGroupData[{

Cell["9. Go easy on pattern matching.", "Section",
 CellChangeTimes->{{3.5184328635503216`*^9, 3.518432872207187*^9}, {
   3.5184330767446384`*^9, 3.5184330886728315`*^9}, {3.5184331625812216`*^9, 
   3.5184331685798216`*^9}, {3.51843359260822*^9, 3.5184336015751166`*^9}, 
   3.5184339650794635`*^9, {3.5184339985448093`*^9, 3.518434010359991*^9}, {
   3.5184344107140226`*^9, 3.5184344162735786`*^9}, 3.5184357087058086`*^9, {
   3.5184376952224407`*^9, 3.5184376952624445`*^9}, 3.530359431389995*^9, 
   3.5316796462594767`*^9, {3.532194671515539*^9, 3.532194672123567*^9}}],

Cell[TextData[{
 "Pattern matching is great. It can make complicated tasks easy to program. \
But it isn\[CloseCurlyQuote]t always fast, especially the fuzzier patterns \
like ",
 StyleBox[ButtonBox["BlankNullSequence",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/BlankNullSequence.html"]\
, None},
  ButtonNote->
   "http://reference.wolfram.com/mathematica/ref/BlankNullSequence.html"], 
  "FunctionLink"],
 " (usually written as \[OpenCurlyDoubleQuote]___\[CloseCurlyDoubleQuote]), \
which can search long and hard through your data for patterns that you, as a \
programmer, might already know will never be there. If execution speed \
matters, use tighter patterns, or none at all.\n\nAs an example, here is a \
rather neat way to implement a ",
 ButtonBox["bubble sort",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://en.wikipedia.org/wiki/Bubble_sort"], None},
  ButtonNote->"http://en.wikipedia.org/wiki/Bubble_sort"],
 " in a single line of code using patterns:"
}], "Text",
 CellChangeTimes->{{3.518434418817833*^9, 3.5184345766566153`*^9}, {
  3.518435731050043*^9, 3.5184357391068487`*^9}, {3.527780038727007*^9, 
  3.527780042190213*^9}, {3.527780462290351*^9, 3.5277804794503813`*^9}, {
  3.5303607680425434`*^9, 3.530360778088961*^9}, {3.530522259777213*^9, 
  3.5305222949127264`*^9}, {3.530523953719186*^9, 3.530523987481809*^9}, {
  3.5305240938919945`*^9, 3.5305240938939953`*^9}, {3.531679653305306*^9, 
  3.5316796874898033`*^9}, {3.531748537321587*^9, 3.531748544038336*^9}}],

Cell[CellGroupData[{

Cell[BoxData[{
 RowBox[{
  RowBox[{"data", "=", 
   RowBox[{"RandomReal", "[", 
    RowBox[{"1", ",", 
     RowBox[{"{", "200", "}"}]}], "]"}]}], ";"}], "\[IndentingNewLine]", 
 RowBox[{
  RowBox[{
   RowBox[{"data", "//.", 
    RowBox[{
     RowBox[{
      RowBox[{"{", 
       RowBox[{"a___", ",", "b_", ",", "c_", ",", "d___"}], "}"}], "/;", 
      RowBox[{"b", ">", "c"}]}], "\[Rule]", 
     RowBox[{"{", 
      RowBox[{"a", ",", "c", ",", "b", ",", "d"}], "}"}]}]}], ";"}], "//", 
  "AbsoluteTiming"}]}], "Input",
 CellChangeTimes->{{3.527780091236699*^9, 3.527780121095152*^9}, {
  3.5277801625912247`*^9, 3.527780184368863*^9}, {3.5305223249087257`*^9, 
  3.5305223294601808`*^9}},
 CellLabel->"In[30]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"2.5272648`7.854195742006245", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{{3.527780161000022*^9, 3.5277801871456676`*^9}, 
   3.5306116265503516`*^9},
 CellLabel->"Out[31]="]
}, Open  ]],

Cell["\<\
Conceptually neat, but slow compared to this procedural approach that I was \
taught when I first learned programming:\
\>", "Text",
 CellChangeTimes->{{3.5277804894187984`*^9, 3.5277804903548007`*^9}, {
  3.527871526839373*^9, 3.527871586082297*^9}, {3.530524104351041*^9, 
  3.5305241052621317`*^9}, {3.531679712361116*^9, 3.531679718590417*^9}}],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"(", 
    RowBox[{
     RowBox[{"flag", "=", "True"}], ";", "\[IndentingNewLine]", 
     RowBox[{"While", "[", 
      RowBox[{
       RowBox[{"TrueQ", "[", "flag", "]"}], ",", "\[IndentingNewLine]", 
       RowBox[{
        RowBox[{"flag", "=", "False"}], ";", "\[IndentingNewLine]", 
        RowBox[{"Do", "[", 
         RowBox[{
          RowBox[{"If", "[", "\[IndentingNewLine]", 
           RowBox[{
            RowBox[{
             RowBox[{"data", "[", 
              RowBox[{"[", "i", "]"}], "]"}], ">", 
             RowBox[{"data", "[", 
              RowBox[{"[", 
               RowBox[{"i", "+", "1"}], "]"}], "]"}]}], ",", 
            "\[IndentingNewLine]", 
            RowBox[{
             RowBox[{"temp", "=", 
              RowBox[{"data", "[", 
               RowBox[{"[", "i", "]"}], "]"}]}], ";", "\[IndentingNewLine]", 
             RowBox[{
              RowBox[{"data", "[", 
               RowBox[{"[", "i", "]"}], "]"}], "=", 
              RowBox[{"data", "[", 
               RowBox[{"[", 
                RowBox[{"i", "+", "1"}], "]"}], "]"}]}], ";", 
             "\[IndentingNewLine]", 
             RowBox[{
              RowBox[{"data", "[", 
               RowBox[{"[", 
                RowBox[{"i", "+", "1"}], "]"}], "]"}], "=", "temp"}], ";", 
             "\[IndentingNewLine]", 
             RowBox[{"flag", "=", "True"}]}]}], "]"}], ",", 
          RowBox[{"{", 
           RowBox[{"i", ",", "1", ",", 
            RowBox[{
             RowBox[{"Length", "[", "data", "]"}], "-", "1"}]}], "}"}]}], 
         "]"}]}]}], "]"}], ";", "\[IndentingNewLine]", "data"}], ")"}], ";"}],
   "//", "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.527780228813341*^9, 3.527780375440998*^9}, {
  3.5277804127562637`*^9, 3.527780429701894*^9}, {3.5278716137090592`*^9, 
  3.5278716223289213`*^9}, {3.5305223208453193`*^9, 3.5305223225794926`*^9}},
 CellLabel->"In[32]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"0.1716044`6.68607341262184", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{{3.5277804093086576`*^9, 3.5277804302478952`*^9}, 
   3.530611629186819*^9},
 CellLabel->"Out[32]="]
}, Open  ]],

Cell["\<\
Of course in this case you should use the built-in function (see tip 3), \
which will use better sorting algorithms than bubble sort.\
\>", "Text",
 CellChangeTimes->{{3.5278716405807457`*^9, 3.5278716697576637`*^9}, {
   3.5303452148131485`*^9, 3.5303452277299714`*^9}, {3.530359470561664*^9, 
   3.5303594707800646`*^9}, {3.5305225394911814`*^9, 3.5305225548437166`*^9}, 
   3.5305248370075603`*^9, {3.531679728638537*^9, 3.53167972903087*^9}, {
   3.5316798224380302`*^9, 3.531679828243499*^9}}],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"Sort", "[", 
    RowBox[{"RandomReal", "[", 
     RowBox[{"1", ",", 
      RowBox[{"{", "200", "}"}]}], "]"}], "]"}], ";"}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.527780192418477*^9, 3.5277802024648943`*^9}},
 CellLabel->"In[33]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"0.`", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{{3.5277801984400873`*^9, 3.5277802069733024`*^9}, 
   3.5306116360353947`*^9},
 CellLabel->"Out[33]="]
}, Open  ]]
}, Open  ]],

Cell[CellGroupData[{

Cell["10. Try doing things differently.", "Section",
 CellChangeTimes->{{3.5184328635503216`*^9, 3.518432872207187*^9}, {
   3.5184330767446384`*^9, 3.5184330886728315`*^9}, {3.5184331625812216`*^9, 
   3.5184331685798216`*^9}, {3.51843359260822*^9, 3.5184336015751166`*^9}, 
   3.5184339650794635`*^9, {3.5184339985448093`*^9, 3.518434010359991*^9}, {
   3.5184344107140226`*^9, 3.5184344162735786`*^9}, {3.518434642964245*^9, 
   3.5184346525882072`*^9}, {3.5184349968196273`*^9, 
   3.5184350186038055`*^9}, {3.5184352192598686`*^9, 3.518435228764819*^9}, {
   3.5184359876056957`*^9, 3.5184359937653117`*^9}, 3.518437699558874*^9, 
   3.530359380175105*^9, {3.530359435898403*^9, 3.5303594361792035`*^9}, 
   3.531679833693572*^9, {3.532194675259603*^9, 3.532194675507477*^9}}],

Cell[TextData[{
 "One of ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 "\[CloseCurlyQuote]s great strengths is that it can tackle the same problem \
in different ways. It allows you to program the way you think, as opposed to \
reconceptualizing the problem for the style of the programming language. \
However, conceptual simplicity is not always the same as computational \
efficiency. Sometimes the easy-to-understand idea does more work than is \
necessary."
}], "Text",
 CellChangeTimes->{{3.527872353249006*^9, 3.5278723547451553`*^9}, 
   3.5278723880694876`*^9, {3.5303453275701466`*^9, 3.530345371484224*^9}, {
   3.5303454151955004`*^9, 3.5303454919388356`*^9}, 3.530360820287035*^9, {
   3.5305225650197344`*^9, 3.530522607413973*^9}, {3.5316798415900917`*^9, 
   3.531679856954521*^9}, 3.531748642644395*^9, {3.532189993309868*^9, 
   3.532189995145186*^9}}],

Cell[TextData[{
 "But another issue is that because special optimizations and smart \
algorithms are applied automatically in ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 ", it is often hard to predict when something clever is going to happen. For \
example, here are two ways of calculating factorial, but the second is over \
10 times faster. "
}], "Text",
 CellChangeTimes->{{3.5303444604416237`*^9, 3.530344550157381*^9}, {
   3.530344600233469*^9, 3.530344801645423*^9}, {3.5303448639685326`*^9, 
   3.530344917102226*^9}, {3.530345498600047*^9, 3.5303455461343307`*^9}, 
   3.531679861132125*^9, {3.531679897561172*^9, 3.531679902227916*^9}}],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"temp", "=", "1"}], ";", 
   RowBox[{"Do", "[", 
    RowBox[{
     RowBox[{"temp", "=", 
      RowBox[{"temp", " ", "i"}]}], ",", 
     RowBox[{"{", 
      RowBox[{"i", ",", 
       RowBox[{"2", "^", "16"}]}], "}"}]}], "]"}], ";"}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.530344231166021*^9, 3.530344278480904*^9}, {
  3.530344318572974*^9, 3.530344363596654*^9}, {3.530360851908291*^9, 
  3.5303608561982985`*^9}},
 CellLabel->"In[35]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"0.8892228`7.4005555831361045", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{
  3.5303442793077054`*^9, {3.530344326622588*^9, 3.5303443650942564`*^9}, 
   3.5306116396078863`*^9, {3.530611684084627*^9, 3.530611716627061*^9}},
 CellLabel->"Out[35]="]
}, Open  ]],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{
  RowBox[{
   RowBox[{"Apply", "[", 
    RowBox[{"Times", ",", 
     RowBox[{"Range", "[", 
      RowBox[{"2", "^", "16"}], "]"}]}], "]"}], ";"}], "//", 
  "AbsoluteTiming"}]], "Input",
 CellChangeTimes->{{3.530344296576936*^9, 3.530344349182228*^9}, {
  3.530360859443104*^9, 3.5303608622199087`*^9}},
 CellLabel->"In[36]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"0.0624016`6.246740718791574", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{{3.530344307559355*^9, 3.5303443495566287`*^9}, {
  3.530611641573537*^9, 3.530611717329079*^9}},
 CellLabel->"Out[36]="]
}, Open  ]],

Cell[TextData[{
 "Why? You might guess that the ",
 StyleBox[ButtonBox["Do",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Do.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Do.html"], 
  "FunctionLink"],
 " loop is slow, or all those ",
 ButtonBox["assignments",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Set.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Set.html"],
 " to ",
 StyleBox["temp",
  FontSlant->"Italic"],
 " take time, or that there is something else \[OpenCurlyDoubleQuote]wrong\
\[CloseCurlyDoubleQuote] with the first implementation, but the real reason \
is probably quite unexpected. ",
 StyleBox[ButtonBox["Times",
  BaseStyle->"Hyperlink",
  ButtonData->{
    URL["http://reference.wolfram.com/mathematica/ref/Times.html"], None},
  ButtonNote->"http://reference.wolfram.com/mathematica/ref/Times.html"], 
  "FunctionLink"],
 " knows a clever binary splitting trick that can be used when you have a \
large number of integer arguments. It is faster to recursively split the \
arguments into two smaller products, (1\[Times]2\[Times]...\[Times]32767)\
\[Times](32768\[Times]...\[Times]65536), rather than working through the \
arguments from first to last. It still has to do the same number of \
multiplications, but fewer of them involve very big integers, and so, on \
average, are quicker to do. There are lots of such pieces of hidden magic in ",
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 ", and more get added with each release.\n\nOf course the best way here is \
to use the built-in function (tip 3 again):"
}], "Text",
 CellChangeTimes->{
  3.5303448042662277`*^9, {3.5303449355570583`*^9, 3.530345169027068*^9}, {
   3.5303455814059925`*^9, 3.530345590313608*^9}, {3.530359476598875*^9, 
   3.5303594769108753`*^9}, {3.53036087421633*^9, 3.5303608857447505`*^9}, {
   3.5303609168356047`*^9, 3.530360918988409*^9}, {3.530522660678299*^9, 
   3.530522671361514*^9}, {3.530522705539765*^9, 3.530522710899372*^9}, 
   3.5305227568711596`*^9, {3.530522797288281*^9, 3.5305228508133335`*^9}, {
   3.5305241447360787`*^9, 3.5305241642710323`*^9}, {3.5305242680294065`*^9, 
   3.530524275408145*^9}, 3.5305248370995603`*^9, 3.531679932804001*^9, {
   3.531679962822941*^9, 3.531680070139244*^9}, 3.5321900645443707`*^9}],

Cell[CellGroupData[{

Cell[BoxData[
 RowBox[{"AbsoluteTiming", "[", 
  RowBox[{
   RowBox[{"65536", "!"}], ";"}], "]"}]], "Input",
 CellChangeTimes->{{3.530344282302911*^9, 3.530344288776922*^9}},
 CellLabel->"In[37]:="],

Cell[BoxData[
 RowBox[{"{", 
  RowBox[{"0.0156004`5.644680727463611", ",", "Null"}], "}"}]], "Output",
 CellChangeTimes->{3.5303442892137227`*^9, 3.5303443528794346`*^9, 
  3.530611725269683*^9},
 CellLabel->"Out[37]="]
}, Open  ]],

Cell[TextData[{
 StyleBox["Mathematica",
  FontSlant->"Italic"],
 " is capable of superb computational performance, and also superb robustness \
and accuracy, but not always both at the same time. I hope that these tips \
will help you to balance the sometimes conflicting needs for rapid \
programming, rapid execution, and accurate results. \n\n",
 StyleBox["All timings use a Windows 7 64-bit PC with 2.66 GHz Intel Core 2 \
Duo and 6 GB RAM.",
  FontSlant->"Italic"]
}], "Text",
 CellChangeTimes->{
  3.530345476182808*^9, 3.5303456177696567`*^9, {3.5303456528853188`*^9, 
   3.530345703554207*^9}, {3.5303457656735163`*^9, 3.530345868446497*^9}, {
   3.5303609588464785`*^9, 3.530361026675398*^9}, {3.5305228880224934`*^9, 
   3.5305229093078766`*^9}, {3.530522947437312*^9, 3.530523004942636*^9}, {
   3.530523050389724*^9, 3.530523166429927*^9}, {3.5306117837087812`*^9, 
   3.53061181016706*^9}, 3.5306118565666494`*^9, {3.5306134994287834`*^9, 
   3.5306135607851567`*^9}, {3.5306135930009828`*^9, 
   3.5306136437334833`*^9}, {3.531680077851529*^9, 3.531680080642832*^9}, {
   3.531748685097601*^9, 3.53174869591341*^9}}]
}, Open  ]]
}, Open  ]]
},
WindowSize->{700, Automatic},
WindowMargins->{{257, Automatic}, {Automatic, 8}},
FrontEndVersion->"8.0 for Mac OS X x86 (32-bit, 64-bit Kernel) (February 23, \
2011)",
StyleDefinitions->Notebook[{
   Cell[
    StyleData[StyleDefinitions -> "Default.nb"]], 
   Cell[
    StyleData[StyleDefinitions -> "StyleMenuClear.nb"]], 
   Cell[
    StyleData["Notebook"], PageWidth -> 520, CellLabelAutoDelete -> False, 
    DefaultNewCellStyle -> "Text", 
    AutoStyleOptions -> {"UndefinedSymbolStyle" -> None}], 
   Cell[
    StyleData["Title"], CellMargins -> {{59, Inherited}, {1, 60}}, 
    MenuSortingValue -> 1000, MenuCommandKey -> "1", FontSize -> 14, 
    FontColor -> RGBColor[0.8, 0, 0]], 
   Cell[
    StyleData["Text"], CellMargins -> {{60, 10}, {8, 7}}, 
    ReturnCreatesNewCell -> True, LineSpacing -> {1, 1.5}, MenuSortingValue -> 
    7000, MenuCommandKey -> "7", FontFamily -> "Helvetica", FontSize -> 12], 
   Cell[
    StyleData["Date", StyleDefinitions -> StyleData["Text"]], 
    CellMargins -> {{60, 10}, {1, 0}}, MenuSortingValue -> 2000, 
    MenuCommandKey -> "2", FontFamily -> "Helvetica", FontSize -> 11], 
   Cell[
    StyleData["Author", StyleDefinitions -> StyleData["Text"]], 
    CellMargins -> {{60, 10}, {5, 1}}, MenuSortingValue -> 3000, 
    MenuCommandKey -> "3", FontFamily -> "Helvetica", FontSize -> 12], 
   Cell[
    CellGroupData[{
      Cell[
       StyleData["TextAnnotation"], CellFrame -> 1, CellFrameColor -> 
       RGBColor[0.8, 0, 0], AutoSpacing -> False, LineIndent -> Automatic, 
       FontSize -> 11, FontWeight -> "Plain", FontColor -> 
       RGBColor[0.4, 0.2, 0.2], Background -> GrayLevel[0.999], 
       ButtonBoxOptions -> {
        Active -> True, Appearance -> "DialogBox", ButtonFunction :> 
         GenerateAnnotationDialog[], Evaluator -> Automatic, Method -> 
         "Queued"}], 
      Cell[
       StyleData["TextAnnotation", "Printout"]]}, Closed]], 
   Cell[
    CellGroupData[{
      Cell[
       StyleData["TextAnnotationButton"], Editable -> False, FontFamily -> 
       "Verdana", FontSize -> 9, ButtonBoxOptions -> {ButtonMargins -> 1}], 
      Cell[
       StyleData["TextAnnotationButton", "Printout"]]}, Closed]], 
   Cell[
    StyleData["Hyperlink"], FontColor -> RGBColor[0.8, 0, 0]], 
   Cell[
    StyleData["FunctionLink", StyleDefinitions -> StyleData["Hyperlink"]], 
    MenuSortingValue -> 10000, FontFamily -> "Courier", FontSize -> 12, 
    FontColor -> RGBColor[0.8, 0, 0]], 
   Cell[
    StyleData["InlineCode"], MenuSortingValue -> 10000, FontFamily -> 
    "Courier"], 
   Cell[
    StyleData["Input"], CellMargins -> {{60, 10}, {5, 10}}, MenuSortingValue -> 
    9000, MenuCommandKey -> "9"], 
   Cell[
    StyleData["Output"], CellMargins -> {{60, 10}, {10, 5}}], 
   Cell[
    StyleData["Program"], CellFrame -> False, 
    CellMargins -> {{60, 4}, {8, 8}}, MenuSortingValue -> 8000, 
    MenuCommandKey -> "8"], 
   Cell[
    StyleData["Picture"], CellMargins -> {{60, Inherited}, {8, 8}}, 
    MenuSortingValue -> 6000, MenuCommandKey -> "6"]}, Visible -> False, 
  FrontEndVersion -> 
  "8.0 for Mac OS X x86 (32-bit, 64-bit Kernel) (February 23, 2011)", 
  StyleDefinitions -> "Default.nb"]
]
(* End of Notebook Content *)

(* Internal cache information *)
(*CellTagsOutline
CellTagsIndex->{}
*)
(*CellTagsIndex
CellTagsIndex->{}
*)
(*NotebookFileOutline
Notebook[{
Cell[CellGroupData[{
Cell[574, 22, 363, 9, 75, "Title"],
Cell[940, 33, 96, 2, 13, "Date",
 CellID->70619275],
Cell[1039, 37, 165, 2, 18, "Author",
 CellID->17557214],
Cell[1207, 41, 1048, 25, 68, "Text"],
Cell[CellGroupData[{
Cell[2280, 70, 339, 6, 89, "Section"],
Cell[2622, 78, 2187, 34, 203, "Text"],
Cell[CellGroupData[{
Cell[4834, 116, 919, 22, 43, "Input"],
Cell[5756, 140, 242, 6, 33, "Output"]
}, Open  ]],
Cell[CellGroupData[{
Cell[6035, 151, 741, 19, 43, "Input"],
Cell[6779, 172, 366, 7, 33, "Output"]
}, Open  ]],
Cell[7160, 182, 754, 13, 81, "Text"],
Cell[CellGroupData[{
Cell[7939, 199, 721, 22, 43, "Input"],
Cell[8663, 223, 830, 21, 43, "Output"]
}, Open  ]],
Cell[9508, 247, 588, 13, 27, "Text"],
Cell[CellGroupData[{
Cell[10121, 264, 724, 21, 43, "Input"],
Cell[10848, 287, 829, 21, 43, "Output"]
}, Open  ]],
Cell[11692, 311, 576, 9, 54, "Text"],
Cell[CellGroupData[{
Cell[12293, 324, 384, 10, 43, "Input"],
Cell[12680, 336, 121, 2, 27, "Output"]
}, Open  ]],
Cell[CellGroupData[{
Cell[12838, 343, 215, 5, 27, "Input"],
Cell[13056, 350, 126, 2, 27, "Output"]
}, Open  ]]
}, Open  ]],
Cell[CellGroupData[{
Cell[13231, 358, 384, 12, 67, "Section"],
Cell[13618, 372, 1731, 34, 135, "Text"],
Cell[15352, 408, 346, 9, 27, "Input"],
Cell[15701, 419, 883, 26, 58, "Input"],
Cell[CellGroupData[{
Cell[16609, 449, 286, 8, 27, "Input"],
Cell[16898, 459, 246, 5, 27, "Output"]
}, Open  ]],
Cell[17159, 467, 614, 15, 28, "Text"],
Cell[17776, 484, 931, 27, 58, "Input"],
Cell[CellGroupData[{
Cell[18732, 515, 310, 8, 27, "Input"],
Cell[19045, 525, 246, 5, 27, "Output"]
}, Open  ]],
Cell[19306, 533, 438, 9, 41, "Text"],
Cell[19747, 544, 1085, 30, 73, "Input"],
Cell[CellGroupData[{
Cell[20857, 578, 284, 7, 27, "Input"],
Cell[21144, 587, 272, 5, 27, "Output"]
}, Open  ]],
Cell[21431, 595, 1717, 42, 95, "Text"]
}, Open  ]],
Cell[CellGroupData[{
Cell[23185, 642, 426, 9, 67, "Section"],
Cell[23614, 653, 2164, 53, 82, "Text"],
Cell[25781, 708, 1201, 32, 88, "Input"],
Cell[CellGroupData[{
Cell[27007, 744, 311, 8, 27, "Input"],
Cell[27321, 754, 170, 4, 27, "Output"]
}, Open  ]]
}, Open  ]],
Cell[CellGroupData[{
Cell[27540, 764, 689, 9, 67, "Section"],
Cell[28232, 775, 2571, 45, 216, "Text"],
Cell[30806, 822, 297, 9, 27, "Input"],
Cell[CellGroupData[{
Cell[31128, 835, 293, 8, 27, "Input"],
Cell[31424, 845, 246, 6, 27, "Output"]
}, Open  ]],
Cell[31685, 854, 789, 15, 82, "Text"],
Cell[CellGroupData[{
Cell[32499, 873, 425, 13, 27, "Input"],
Cell[32927, 888, 269, 5, 27, "Output"]
}, Open  ]],
Cell[33211, 896, 278, 6, 27, "Text"]
}, Open  ]],
Cell[CellGroupData[{
Cell[33526, 907, 727, 13, 67, "Section"],
Cell[34256, 922, 2847, 55, 231, "Text"],
Cell[CellGroupData[{
Cell[37128, 981, 806, 23, 73, "Input"],
Cell[37937, 1006, 194, 4, 27, "Output"]
}, Open  ]],
Cell[38146, 1013, 592, 10, 81, "Text"]
}, Open  ]],
Cell[CellGroupData[{
Cell[38775, 1028, 728, 9, 89, "Section"],
Cell[39506, 1039, 456, 9, 41, "Text"],
Cell[39965, 1050, 366, 9, 27, "Input"],
Cell[40334, 1061, 1387, 23, 95, "Text"],
Cell[41724, 1086, 549, 14, 27, "Input"],
Cell[42276, 1102, 528, 11, 54, "Text"]
}, Open  ]],
Cell[CellGroupData[{
Cell[42841, 1118, 329, 4, 67, "Section"],
Cell[43173, 1124, 3186, 74, 220, "Text"],
Cell[CellGroupData[{
Cell[46384, 1202, 482, 14, 43, "Input"],
Cell[46869, 1218, 296, 6, 27, "Output"]
}, Open  ]],
Cell[CellGroupData[{
Cell[47202, 1229, 435, 13, 43, "Input"],
Cell[47640, 1244, 245, 5, 27, "Output"]
}, Open  ]],
Cell[47900, 1252, 378, 9, 54, "Text"]
}, Open  ]],
Cell[CellGroupData[{
Cell[48315, 1266, 730, 15, 67, "Section"],
Cell[49048, 1283, 1275, 29, 68, "Text"]
}, Open  ]],
Cell[CellGroupData[{
Cell[50360, 1317, 671, 15, 89, "Section"],
Cell[51034, 1334, 2357, 53, 152, "Text"],
Cell[CellGroupData[{
Cell[53416, 1391, 613, 16, 43, "Input"],
Cell[54032, 1409, 271, 6, 27, "Output"]
}, Open  ]],
Cell[CellGroupData[{
Cell[54340, 1420, 681, 18, 43, "Input"],
Cell[55024, 1440, 245, 5, 27, "Output"]
}, Open  ]]
}, Open  ]],
Cell[CellGroupData[{
Cell[55318, 1451, 661, 14, 67, "Section"],
Cell[55982, 1467, 2747, 68, 68, "Text"],
Cell[CellGroupData[{
Cell[58754, 1539, 516, 15, 27, "Input"],
Cell[59273, 1556, 294, 6, 27, "Output"]
}, Open  ]],
Cell[CellGroupData[{
Cell[59604, 1567, 466, 14, 27, "Input"],
Cell[60073, 1583, 217, 5, 27, "Output"]
}, Open  ]]
}, Open  ]],
Cell[CellGroupData[{
Cell[60339, 1594, 577, 7, 67, "Section"],
Cell[60919, 1603, 1559, 30, 122, "Text"],
Cell[CellGroupData[{
Cell[62503, 1637, 712, 20, 58, "Input"],
Cell[63218, 1659, 222, 5, 27, "Output"]
}, Open  ]],
Cell[63455, 1667, 358, 6, 41, "Text"],
Cell[CellGroupData[{
Cell[63838, 1677, 1947, 48, 163, "Input"],
Cell[65788, 1727, 221, 5, 27, "Output"]
}, Open  ]],
Cell[66024, 1735, 508, 8, 41, "Text"],
Cell[CellGroupData[{
Cell[66557, 1747, 302, 9, 27, "Input"],
Cell[66862, 1758, 200, 5, 27, "Output"]
}, Open  ]]
}, Open  ]],
Cell[CellGroupData[{
Cell[67111, 1769, 781, 10, 67, "Section"],
Cell[67895, 1781, 877, 16, 81, "Text"],
Cell[68775, 1799, 656, 12, 68, "Text"],
Cell[CellGroupData[{
Cell[69456, 1815, 507, 15, 27, "Input"],
Cell[69966, 1832, 296, 6, 27, "Output"]
}, Open  ]],
Cell[CellGroupData[{
Cell[70299, 1843, 350, 10, 27, "Input"],
Cell[70652, 1855, 243, 5, 27, "Output"]
}, Open  ]],
Cell[70910, 1863, 2411, 47, 176, "Text"],
Cell[CellGroupData[{
Cell[73346, 1914, 198, 5, 27, "Input"],
Cell[73547, 1921, 219, 5, 27, "Output"]
}, Open  ]],
Cell[73781, 1929, 1131, 20, 108, "Text"]
}, Open  ]]
}, Open  ]]
}
]
*)

(* End of internal cache information *)

(* NotebookSignature Lw0@bVGVQJHthBwfEpUN8vEY *)
