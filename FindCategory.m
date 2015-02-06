function category = FindCategory(structures, atlas)
% FindCategory compares a list of plan structures to an atlas and returns
% the most likely plan category (Brain, HN, Thorax, Abdomen, Pelvis, etc).
% If no category is found, the returned string is 'Other'.
%
% The following variables are required for proper execution: 
%   structures: cell array of structure names. See LoadReferenceStructures
%       for more information.
%   atlas: cell array of atlas names, include/exclude regex statements,
%       and categories.  See LoadAtlas for more information.
%
% The following variables are returned upon succesful completion:
%   category: string representing the category which matched the most
%       structures.  If the algorithm cannot find any matches, 'Other' will
%       be returned.
%
% Below is an example of how this function is used:
%
%   % Load DICOM images
%   path = '/path/to/files/';
%   names = {
%       '2.16.840.1.114362.1.5.1.0.101218.5981035325.299641582.274.1.dcm'
%       '2.16.840.1.114362.1.5.1.0.101218.5981035325.299641582.274.2.dcm'
%       '2.16.840.1.114362.1.5.1.0.101218.5981035325.299641582.274.3.dcm'
%   };
%   image = LoadDICOMImages(path, names);
%
%   % Load DICOM structure set 
%   name = '2.16.840.1.114362.1.5.1.0.101218.5981035325.299641579.747.dcm';
%   structures = LoadDICOMStructures(path, name, image);
%
%   % Load the structure atlas
%   atlas = LoadAtlas('atlas.xml');
%
%   % Find category of DICOM structure set
%   category = FindCategory(structures, atlas);
%
% Author: Mark Geurts, mark.w.geurts@gmail.com
% Copyright (C) 2015 University of Wisconsin Board of Regents
%
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the  
% Free Software Foundation, either version 3 of the License, or (at your 
% option) any later version.
%
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with this program. If not, see http://www.gnu.org/licenses/.

% Log start of search, and start timer
if exist('Event', 'file') == 2
    Event('Searching for plan category using structure names');
    tic;
end

% Initialize cell array for category candidates
matches = cell(0);

% Loop through all provided structures
for i = 1:length(structures)
    
    % Loop through each atlas structure
    for j = 1:length(atlas)
        
        % If the atlas structure is associated with a plan category
        if isfield(atlas{j}, 'category')
            
            % Run atlas include REGEXP against structure name
            in = regexpi(structures{i}.name, atlas{j}.include);
            
            % If the atlas structure has an exclude statement as well
            if isfield(atlas{j}, 'exclude') 
                
                % Run atlas exclude REGEXP against structure name
                ex = regexpi(structures{i}.name, atlas{j}.exclude);
            else
                
                % Otherwise, return zero matches (empty array)
                ex = [];
            end
            
            % If the include matched at least once and the exclude didn't
            if size(in,1) > 0 && size(ex,1) == 0
                
                % Loop through atlas categories
                for k = 1:size(atlas{j}.category,2)
                    
                    % Add the category to the list of matched categories
                    matches{size(matches,2)+1} = atlas{j}.category{k};
                end
                
                % Break the atlas search loop, since an atlas value
                % matched with the structure
                break;
            end
        end
    end
    
    % Clear temporary variables
    clear in ex;
end

% Clear temporary variables
clear i j k;

% If at least one matching atlas structure with a category was found
if ~isempty(matches)
    
    % Determine frequency of unique values in matches cell array
    [C, ~, ic] = unique(matches);
    
    % Return the most frequency category matched
    category = char(C(mode(ic)));
    
    % Clear temporary variables
    clear C ic;
else
    
    % Otherwise, return "Other"
    category = 'Other';
end

% Log completion of function
if exist('Event', 'file') == 2
    Event(sprintf('Category identified as %s in %0.3f seconds', ...
        category, toc));
end

% Clear temporary variables
clear matches;
