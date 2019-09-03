function write_MakeFile(modelname, dataFlag, pythonversion, mypath)

    fileID = fopen('Makefile','w');
    fprintf(fileID,'PYTHONPATH = %s\n', mypath);
    fprintf(fileID,'MODELNAME = %s\n', modelname);
    fprintf(fileID,'PYVERSION = %s\n', pythonversion);
    fprintf(fileID,'all: \n');
    fprintf(fileID,'\tcython -3 $(MODELNAME).pyx -o $(MODELNAME).pyx.c \n');
    fprintf(fileID,'\tgcc -fPIC -I. -I$(PYTHONPATH)/include/ -I$(PYTHONPATH)/include/python$(PYVERSION)m/ -o $(MODELNAME).pyx.o -c $(MODELNAME).pyx.c \n');
    if dataFlag == 1
        fprintf(fileID,'\tgcc -shared -fPIC $(MODELNAME).o $(MODELNAME)_data.o $(MODELNAME).pyx.o -o $(MODELNAME).so');
    else
        fprintf(fileID,'\tgcc -shared -fPIC $(MODELNAME).o $(MODELNAME).pyx.o -o $(MODELNAME).so');
    end
    fclose(fileID);

end