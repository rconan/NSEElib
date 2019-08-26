function write_function_pyx(block_name, reference_size, feedback_size, output_size)

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

fprintf(fileID,'cdef list inputs, outputs\n');
if reference_size ~= 0
 fprintf(fileID,'inputs = [(''reference'',%i),(''feedback'',%i)]\n',reference_size,feedback_size);
else
 fprintf(fileID,'inputs = [(''feedback'',%i)]\n',feedback_size);
end
fprintf(fileID,'outputs  = [(''output'',%i)]\n\n',output_size);


fprintf(fileID,'def Initialize():\n');
fprintf(fileID,'\t%s_initialize()\n\n',block_name);


fprintf(fileID,'def Step():\n');
fprintf(fileID,'\t%s_step()\n\n',block_name);


fprintf(fileID,'def Terminate():\n');
fprintf(fileID,'\t%s_terminate()\n\n',block_name);


fprintf(fileID,'def Next(double [:] output):\n');
fprintf(fileID,'\tcdef int k\n');
fprintf(fileID,'\t%s_step()\n',block_name);
fprintf(fileID,'\tfor k in range(%i):\n',output_size);
fprintf(fileID,'\t\toutput[k] = %s_Y.Output[k]\n\n',block_name);


fprintf(fileID,'def Set_U(double [:] reference, double [:] feedback):\n');
fprintf(fileID,'\tcdef int k\n');
fprintf(fileID,'\tfor k in range(%i):\n',feedback_size);
fprintf(fileID,'\t\t%s_U.Feedback[k] = feedback[k]\n',block_name);
if reference_size ~= 0
fprintf(fileID,'\tfor k in range(%i):\n',reference_size);
fprintf(fileID,'\t\t%s_U.Reference[k] = reference[k]\n',block_name);
end

fclose(fileID);
        
end