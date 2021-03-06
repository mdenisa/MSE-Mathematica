(*http://mathematica.stackexchange.com/questions/6144/looking-for-longest-common-substring-solution/6376#6376*)

BeginPackage["SimpleJavaReloader`", {"JLink`"}];

JCompileLoad::usage = 
"JCompileLoad[javacode_,addToClassPath_] attempts to compile a Java \
class defined by  a string javacode, optionally adding to Java compiler classpath \
files and folders from addToClassPath, and load the resulting class into 
Mathematica";

Begin["`Private`"]

JCompileLoad::dirmakeerr = "Can not create directory `1`";

$stateValid = True;

$tempJavaDirectory =  FileNameJoin[{$UserBaseDirectory, "Temp", "Java"}];
    $tempClassDirectory = FileNameJoin[{$tempJavaDirectory, "Classes"}];
    $tempJavaLogDirectory = FileNameJoin[{$tempJavaDirectory, "Logs"}];
    $tempCompileLogFile =   FileNameJoin[{$tempJavaLogDirectory, "javac.log"}];
    $jrePath =   
     FileNameJoin[{$InstallationDirectory, "SystemFiles", "Java", $SystemID}];
$javaPath = FileNameJoin[{$jrePath, "bin"}];
    $jlibPath = FileNameJoin[{$jrePath, "lib"}];
    $classPath = {$tempClassDirectory, $jlibPath};


Scan[
   If[! FileExistsQ[#] && CreateDirectory[#] === $Failed,
          Message[JCompileLoad::dirmakeerr, #];
          $stateValid = False
   ] &,
   {
     $tempJavaDirectory,
         $tempClassDirectory,
     $tempJavaLogDirectory
   }];



(* determine a short name of the class from code *)
Clear[getClass];
getClass[classCode_String] :=
  With[{cl =
     StringCases[classCode, 
       "public" ~~ Whitespace ~~ "class"|"interface" ~~ Whitespace ~~ 
         name : (WordCharacter ..) :> name
     ]},
    First@cl /; cl =!= {}];

getClass[__] := Throw[$Failed, error[getClass]];

(* Determine the name of the package for the class *) 
Clear[getPackage];
getPackage[classCode_String] :=
  With[{pk = 
      StringCases[classCode, 
          ShortestMatch["package" ~~ Whitespace ~~ p__ ~~ ";"] :> p
      ]},
    First@pk /; pk =!= {}];

getPackage[classCode_String] := None;

getPackage[__] := Throw[$Failed, error[getPackage]];


ClearAll[getFullClass];
getFullClass[classCode_String] :=
   StringJoin[If[# === None, "", # <> "."] &@
      getPackage[classCode], getClass[classCode]];

(* Note: So far, tested on Windows only. Some specifics of quoting are 
   tuned to work around some bugs in Windows command line processor *)
Clear[makeCompileScript];
makeCompileScript[sourceFile_String] :=
  StringJoin[
    "\"",
    "\"", FileNameJoin[{$javaPath, "javac"}] , "\"",
        " -g ", sourceFile,
        " -d ", $tempClassDirectory,
    " -classpath ", "\"", Sequence @@ Riffle[$classPath, ";"], "\"",
        " 2> ", $tempCompileLogFile,
    "\""
  ];

Clear[getSourceFile];
getSourceFile[javacode_String] :=
   FileNameJoin[{$tempClassDirectory, getClass[javacode] <> ".java"}];

Clear[JCompileLoad];

JCompileLoad::invst =  "The loader is not on valid state. Perhaps some temporary \
     directories do not exist";

JCompileLoad::cmperr = "The following compilation errors were encountered: `1`";

JCompileLoad[javacode_String, addToClassPath_: {}]/; $stateValid :=
      Module[{sourceFile, fullClassName = getFullClass[javacode]},
         sourceFile = getSourceFile[javacode];
         With[{script =
            Block[{$classPath = Join[$classPath, addToClassPath]},
               makeCompileScript[sourceFile]
            ]},
           Export[sourceFile, javacode, "String"];
           If[Run[script] =!= 0,
             Message[
                JCompileLoad::cmperr, 
                Style[#, Red] &@Import[$tempCompileLogFile, "String"]
         ];
         $Failed,
             (*else*)
             ReinstallJava[];
             AddToClassPath @@ Join[$classPath, addToClassPath];
         LoadJavaClass[fullClassName]
       ]
     ]
  ];

JCompileLoad[_String, addToClassPath_: {}] :=
  (
     Message[JCompileLoad::invst];
     $Failed
  )

End[]

EndPackage[]