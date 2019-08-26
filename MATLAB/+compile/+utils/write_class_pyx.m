function write_class_pyx(block_name, alias, reference_size, feedback_size, output_size)

filename = block_name + '.pyx'
fileID = fopen(filename,'w');
fprintf(fileID,'cdef extern from "%s.h":\n', block_name);
fprintf(fileID,'\tctypedef double real_T\n');
fprintf(fileID,'\tctypedef struct ExtU_%s_T:\n',block_name);
if reference_size ~= 0
 fprintf(fileID,'\t\treal_T Reference[%i] #                /* ''<Root>/Reference'' */\n',reference_size);
end
fprintf(fileID,'\t\treal_T Feedback[%i] #                /* ''<Root>/Feedback'' */\n',feedback_size);
fprintf(fileID,'\tctypedef struct ExtY_%s_T:\n',block_name);
fprintf(fileID,'\t\treal_T Output[%i] #                  /* ''<Root>/Output'' */\n',output_size);
fprintf(fileID,'\tExtU_%s_T %s_U\n',block_name,block_name);
fprintf(fileID,'\tExtY_%s_T %s_Y\n',block_name,block_name);

fprintf(fileID,'\tvoid %s_initialize()\n',block_name);
fprintf(fileID,'\tvoid %s_step()\n',block_name);
fprintf(fileID,'\tvoid %s_terminate()\n\n',block_name);

fprintf(fileID, 'outputs = [None] * %i\n\n', output_size);
% Define Class
fprintf(fileID, 'class %sObj: \n\n', alias);
% Define Start
fprintf(fileID, '\tdef start():\n');
fprintf(fileID, '\t\t%s_initialize()\n\n', block_name);
% Define Update
if reference_size ~= 0
 fprintf(fileID, '\tdef update(double [:] reference, double [:] feedback):\n');
else
 fprintf(fileID, '\tdef update(double [:] feedback):\n');   
end
fprintf(fileID, '\t\tcdef int k\n');
if reference_size ~= 0
 fprintf(fileID, '\t\tfor k in range(%i):\n', reference_size);
 fprintf(fileID, '\t\t\t%s_U.Reference[k] = reference[k]\n', block_name);
end
fprintf(fileID, '\t\tfor k in range(%i):\n', feedback_size);
fprintf(fileID, '\t\t\t%s_U.Feedback[k] = feedback[k]\n', block_name);
fprintf(fileID, '\t\t%s_step()\n\n', block_name);
% Define Output
fprintf(fileID, '\tdef output():\n');
fprintf(fileID, '\t\tcdef int k\n');
fprintf(fileID, '\t\tfor k in range(%i):\n', output_size);
fprintf(fileID, '\t\t\toutputs[k] = %s_Y.Output[k]\n', block_name);
fprintf(fileID, '\t\tdoutput = {''%s'' : outputs}\n', lower(alias));
fprintf(fileID, '\t\treturn doutput\n\n');
% Define Terminate
fprintf(fileID, '\tdef terminate():\n');
fprintf(fileID, '\t\t%s_terminate()', block_name);

fclose(fileID);
        
end