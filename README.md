# RT Structure Atlas Matching Tools

by Mark Geurts mark.w.geurts@gmail.com 
<br>Copyright&copy; 2015, University of Wisconsin Board of Regents

The RT Structure Atlas Matching Tools are a compilation of functions that are used to match structures from radiotherapy plans for determining dosimetric objectives, plan types (head and neck, pelvis, etc), or standardizing names.  The atlas is specified as an XML file (a generic atlas.xml is provided in this repository).  

The atlas uses a pair of regular expressions; the first expression matches phrases included in the structure name, while the second matches phrases that are excluded.  If a structure name matches the inclusion statement and not the exclusion statement, it is considered to be matched.  Additional fields can be added to each atlas structure to specify additional properties about the structure (see below for examples).

The following structure illustrates how each structure is composed in the XML file:

```xml
 <atlas version="1.0">
   <structure>
      <name></name>
      <include></include>
      <exclude></exclude>
      
      ... structure property tags ...
      
   </structure>
 </atlas>
```

## Contents

* [Installation and Use](README.md#installation-and-use)
* [Compatibility and Requirements](README.md#compatibility-and-requirements)
* [Tools and Examples](README.md#tools-and-examples)
  * [LoadAtlas](README.md#loadatlas)
  * [FindCategory](README.md#findcategory)
* [Event Calling](README.md#event-calling)
* [License](README.md#license)

## Installation and Use

To install the RT Structure Atlas Matching Tools, copy all MATLAB .m files and .xml files from this repository into your MATLAB path. If installing as a submodule into another git repository, execute `git submodule add https://github.com/mwgeurts/structure_atlas`.

## Compatibility and Requirements

The RT Structure Atlas Matching Tools have been validated for MATLAB versions 8.3 through 8.5 on Macintosh OSX 10.8 (Mountain Lion) through 10.10 (Yosemite). These tools use the MATLAB function `xmlread()` and XML Document Object Model features to parse the atlas source file.

## Tools and Examples

The following subsections describe what inputs and return variables are used, and provides examples for basic operation of each tool. For more information, refer to the documentation within the source code.

### LoadAtlas

`LoadAtlas()` reads in a provided XML filename (typically atlas.xml) and parses it into an atlas structure object. See `FindCategory()` to see an example of how the atlas object is used. The following XML format is required, where the exclude, dx, and category elements are optional. Finally, as shown below, multiple category elements may exist (the same structure may be present in multiple plan categories).

```xml
<atlas version="1.0">
  <structure>
     <name></name>
     <include></include>
     <exclude></exclude>
     <load></load>
     <dx></dx>
     <category></category>
     <category></category>
  </structure>
</atlas>
```

This function will parse the name, include, and exclude elements as char arrays, the load element will be parsed as a logical, the dx element as double, and the category elements as a string cell array.

The following variables are required for proper execution: 

* filename: relative path/file name of atlas XML file

The following variables are returned upon succesful completion:

* atlas: cell array of atlas structures with the following fields: name, include, exclude, load, dx, and category

Below is an example of how this function is used:

```matlab
% Load the structure atlas
atlas = LoadAtlas('atlas.xml');
```

### FindCategory

FindCategory compares a list of plan structures to an atlas and returns the most likely plan category (Brain, HN, Thorax, Abdomen, Pelvis, etc). If no category is found, the returned string is 'Other'.

The following variables are required for proper execution: 

* structures: cell array of structure names. See LoadReferenceStructures for more information.
* atlas: cell array of atlas names, include/exclude regex statements, and categories.  See LoadAtlas for more information.

The following variables are returned upon succesful completion:

* category: string representing the category which matched the most structures.  If the algorithm cannot find any matches, 'Other' will be returned.

Below is an example of how this function is used:

```matlab
% Load DICOM images
path = '/path/to/files/';
names = {
    '2.16.840.1.114362.1.5.1.0.101218.5981035325.299641582.274.1.dcm'
    '2.16.840.1.114362.1.5.1.0.101218.5981035325.299641582.274.2.dcm'
    '2.16.840.1.114362.1.5.1.0.101218.5981035325.299641582.274.3.dcm'
};
image = LoadDICOMImages(path, names);

% Load DICOM structure set 
name = '2.16.840.1.114362.1.5.1.0.101218.5981035325.299641579.747.dcm';
structures = LoadDICOMStructures(path, name, image);

% Load the structure atlas
atlas = LoadAtlas('atlas.xml');

% Find category of DICOM structure set
category = FindCategory(structures, atlas);
```

## Event Calling

These functions optionally return execution status and error information to an `Event()` function. If available in the MATLAB path, `Event()` will be called with one or two variables: the first variable is a string containing the status information, while the second is the status classification (WARN or ERROR). If the status information is only informative, the second argument is not included.  Finally, if no `Event()` function is available errors will still be thrown via the standard `error()` MATLAB function.

## License

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
