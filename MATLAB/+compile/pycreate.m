function pycreate(blockname, Ts, flag_class, pyversion, pypath)
%{
                     _ _     ___      _    ___         _             
   __ ___ _ __  _ __(_) |___/ __|_  _| |__/ __|_  _ __| |_ ___ _ __  
  / _/ _ \ '  \| '_ \ | / -_)__ \ || | '_ \__ \ || (_-<  _/ -_) '  \ 
  \__\___/_|_|_| .__/_|_\___|___/\_,_|_.__/___/\_, /__/\__\___|_|_|_|
               |_|                             |__/                  
  
                                                        Version 0.0.1
  
                        Marcelo Lafeta <marcelolafeta.nsee@gmail.com>
                               Felipe Ippolito <feippolito@gmail.com>

  ===================================================================
  
    - Inputs: 
              - blockname (str): the name of the block on simuLink. Make
                   shure that one have no special characteres such 'space', 
                   '*', '/' ... and so on.
              
              - Ts (num): the block sampling time in seconds.
              
              - flag_class (bool): default is true, if so, it creates the
                   cython mask as an python object. If false, creates
                   individual functions. The structure of both are
                   presented below.

              - pyversion (num): the python version on your machine,
                   default is 3.7.

              - pypath (str): the path to your python environment on the
                   machine that you will build the wrapper.
  
    - Outputs: It will create two directories on the same path as the
        chosen simuLink file. The folders will be called:

            - ${blockname}_ert_rtw: here you will find all the files
                    created by the MATLAB compiler. This folder is just a
                    backup for your project.

            - ${blockname}System: here it will have the same files as in
                    the first folder, with two new added: the Makefile and 
                    the ${blockname}.pyx. This is the folder that you will
                    make you library with !make on terminal.

  =================================================================== 

    Observations: to make shure that everything will be fine, we advise
        that you use an unix operational system, due to the simple
        technique of making the directory with !make and the structure
        provided by gcc GNU compiler.

  =================================================================== 
  
  Copyright (C) [2019] Marcelo Lafeta and Felipe Ippolito
  
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the
 *  "Software"), to deal in the Software without restriction, including
 *  without limitation the rights to use, copy, modify, merge, publish,
 *  distribute, sublicense, and/or sell copies of the Software, and to
 *  permit persons to whom the Software is furnished to do so, subject to
 *  the following conditions:
 *  
 *  The above copyright notice and this permission notice shall be
 *  included in all copies or substantial portions of the Software.
 *  
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 *  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 *  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 *  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 *  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 *  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  
  ===================================================================
  
 %}
                    
%% Get the correct paths

original_path = cd;     % Get current path
addpath(original_path); % Use script from root folder

[filename, filepath] = uigetfile();

cd(filepath);

load_system(filename);

model_name = gcs;

%% Specify some model preferences

set_param(model_name, 'SolverType', 'Fixed-step',...
                      'FixedStep', num2str(Ts),...
                      'SystemTargetFile', 'ert.tlc',...
                      'LaunchReport', 'off');
save_system(filename);
%% 

simulink_block = string(model_name) + "/" + string(blockname); % gcb(model_name); % Get Simulink/Block

split_string = strsplit(simulink_block,'/'); % Separate string
block_name = string(split_string(2)); % Block name

%% Subsystem compilation

%rtwbuild(simulink_block, 'OpenBuildStatusAutomatically', false);

close_system(filename);

%% Directory preparations

% Change directories
try 
    alias = block_name;
    backup_folder = block_name + '_ert_rtw'; % New folder name
    copyfile(backup_folder, block_name + 'Controller')
    cd(block_name + 'Controller');
catch
    alias = block_name;
    block_name = block_name + '0';
    backup_folder = block_name + '_ert_rtw';
    copyfile(backup_folder, block_name + 'Controller')
    cd(block_name + 'Controller');
end

%% Get block input and output dizes

controller_path = cd;
h_path = controller_path + "\" + block_name + ".h";

[reference_size, feedback_size, output_size] = GetSizes(h_path, 'Reference','Feedback','Output');

%% Check for _data.o file

files = ls;
for i = 1:length(files(:,1))
    name = strtrim(files(i,:));
    data_flag = contains(name, block_name+'_data.o');
    if data_flag == 1
        break
    end
end

%% Wrapper

% Write the python wrappper on ${blockname}System
if flag_class
    write_class_pyx(block_name, alias, ...
       reference_size, feedback_size, output_size);
else    
    write_function_pyx(block_name, ...
        reference_size, feedback_size, output_size);
end

% Write the Makefile on ${blockname}System
write_MakeFile(block_name, data_flag, pyversion, pypath)

%auxpath = "../" + string(block_name) + "Controller";

%copyfile(auxpath, original_path + "/simulator/pyfuncs/" + string(block_name) + "Controller");

cd(original_path) % Return to original path

end