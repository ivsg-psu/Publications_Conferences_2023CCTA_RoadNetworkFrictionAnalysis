function fcn_VD_checkInputsToFunctions(variable,variable_type_string)
%% fcn_VD_checkInputsToFunctions
%   Checks the variable types commonly used in the Vehicle Dynamics (VD)
%   library to ensure that they are correctly formed. This function is
%   typically called at the top of most functions in VD library. The input
%   is a variable and a string defining the "type" of the variable. This
%   function checks to see that they are compatible.
%
% FORMAT:
%
%      fcn_VD_checkInputsToFunctions(variable,variable_type_string)
%
% INPUTS:
%
%   variable: the variable to check
%   variable_type_string: a string representing the variable type to check.
%   The current strings include:
%       'string': A string input
%
%       'number': A real number.
%
%       'vector3': A 3x1 vector of real numbers.
%
%       'vector2': A 2x1 vector of real numbers.
%
%       'non negative': A non-negative number.
%
%       'positive': A positive number.
%
%       'positive integer': A positive integer.
%
%   Note that the variable_type_string is not case sensitive: for example,
%   'vd' and 'Vd' or 'VD' all give the same result.
%
% OUTPUTS:
%
%   No explicit outputs, but produces MATLAB error outputs if conditions
%   not met, with explanation within the error outputs of the problem.
%
% This function was written on 2021/05/16 by Satya Prasad
% Questions or comments? szm888@psu.edu
%

flag_do_debug = 0; % Flag to debug the results
flag_check_inputs = 0; % Flag to perform input checking

if flag_do_debug
    st = dbstack; %#ok<*UNRCH>
    fprintf(1, 'STARTING function: %s, in file: %s\n', st(1).name, st(1).file);
end

%% check input arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____                   _
%  |_   _|                 | |
%    | |  _ __  _ __  _   _| |_ ___
%    | | | '_ \| '_ \| | | | __/ __|
%   _| |_| | | | |_) | |_| | |_\__ \
%  |_____|_| |_| .__/ \__,_|\__|___/
%              | |
%              |_|
% See: http://patorjk.com/software/taag/#p=display&f=Big&t=Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 1 == flag_check_inputs
    % Are there the right number of inputs?
    if 2~=nargin
        error('Incorrect number of input arguments')
    end
    
    % Check the string input, make sure it is characters
    if ~ischar(variable_type_string)
        error('The variable_type_string input must be a string type, for example: ''Integer'' ');
    end
    
    %% Start of main code
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   __  __       _
    %  |  \/  |     (_)
    %  | \  / | __ _ _ _ __
    %  | |\/| |/ _` | | '_ \
    %  | |  | | (_| | | | | |
    %  |_|  |_|\__,_|_|_| |_|
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    variable_name = inputname(1); % Grab the variable name
    variable_type_string = lower(variable_type_string); % Make the variable lower case
    
    %% A String
    if strcmpi(variable_type_string,'string')
        % Check if the input type is 'string'
        if ~ischar(variable)
            error('The %s input must be string', variable_name);
        end
    end
    
    %% A Function Handle
    if strcmpi(variable_type_string,'function handle')
        % Check if the input type is 'function handle'
        if ~isa(variable,'function_handle')
            error('The %s input must be function handle', variable_name);
        end
    end
    
    %% Any Real Number
    if strcmpi(variable_type_string,'number')
        % Check if the input type is 'real number'
        if ~isnumeric(variable) || ~isreal(variable) || 1~=numel(variable)
            error('The %s input must be a real number', variable_name);
        end
    end
    
    %% 4x2 matrix
    if strcmpi(variable_type_string,'matrix4by2')
        % Check if the input type is 'matrix4by2'
        if ~isnumeric(variable) || ~isreal(variable) || 4~=size(variable,1) || ...
                2~=size(variable,2)
            error('The %s input must be a 4x2 matrix of real numbers', variable_name);
        end
    end
    
    %% 10x1 vector
    if strcmpi(variable_type_string,'vector10')
        % Check if the input type is 'vector10'
        if ~isnumeric(variable) || ~isreal(variable) || 10~=size(variable,1) || ...
                1~=size(variable,2)
            error('The %s input must be a 10x1 vector of real numbers', variable_name);
        end
    end
    
    %% 7x1 vector
    if strcmpi(variable_type_string,'vector7')
        % Check if the input type is 'vector7'
        if ~isnumeric(variable) || ~isreal(variable) || 7~=size(variable,1) || ...
                1~=size(variable,2)
            error('The %s input must be a 7x1 vector of real numbers', variable_name);
        end
    end
    
    %% 5x1 vector
    if strcmpi(variable_type_string,'vector5')
        % Check if the input type is 'vector5'
        if ~isnumeric(variable) || ~isreal(variable) || 5~=size(variable,1) || ...
                1~=size(variable,2)
            error('The %s input must be a 5x1 vector of real numbers', variable_name);
        end
    end
    
    %% 4x1 vector
    if strcmpi(variable_type_string,'vector4')
        % Check if the input type is 'vector4'
        if ~isnumeric(variable) || ~isreal(variable) || 4~=size(variable,1) || ...
                1~=size(variable,2)
            error('The %s input must be a 4x1 vector of real numbers', variable_name);
        end
    end
    
    %% 3x1 vector
    if strcmpi(variable_type_string,'vector3')
        % Check if the input type is 'vector3'
        if ~isnumeric(variable) || ~isreal(variable) || 3~=size(variable,1) || ...
                1~=size(variable,2)
            error('The %s input must be a 3x1 vector of real numbers', variable_name);
        end
    end
    
    %% 2x1 vector
    if strcmpi(variable_type_string,'vector2')
        % Check if the input type is 'vector2'
        if ~isnumeric(variable) || ~isreal(variable) || 2~=size(variable,1) || ...
                1~=size(variable,2)
            error('The %s input must be a 2x1 vector of real numbers', variable_name);
        end
    end
    
    %% Non-Negative Number
    if strcmpi(variable_type_string,'non negative')
        % Check if the input type is 'non-negative real number'
        if ~isnumeric(variable) || ~isreal(variable) || 1~=numel(variable) ...
                || 0>variable
            error('The %s input must be a non-negative number', variable_name);
        end
    end
    
    %% Positive Real Number
    if strcmpi(variable_type_string,'positive')
        % Check if the input type is 'positive real number'
        if ~isnumeric(variable) || ~isreal(variable) || 1~=numel(variable) ...
                || 0>=variable
            error('The %s input must be a positive number', variable_name);
        end
    end
    
    %% Positive Integer
    if strcmpi(variable_type_string,'positive integer')
        % Check if the input type is 'positive integer'
        if ~isnumeric(variable) || ~isreal(variable) || 1~=numel(variable) || ...
                0>=variable || floor(variable)~=variable
            error('The %s input must be a positive integer', variable_name);
        end
    end
end

%% Debugging?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   _____       _
%  |  __ \     | |
%  | |  | | ___| |__  _   _  __ _
%  | |  | |/ _ \ '_ \| | | |/ _` |
%  | |__| |  __/ |_) | |_| | (_| |
%  |_____/ \___|_.__/ \__,_|\__, |
%                            __/ |
%                           |___/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if flag_do_debug
    fprintf(1, 'The variable: %s was checked that it meets type: %s, and no errors were detected.\n', variable_name, variable_type_string);
    fprintf(1, 'ENDING function: %s, in file: %s\n\n', st(1).name, st(1).file);
end

end
