function bootstrapci_figure(dir_bootstrapci,pair,obj,n,nseed,B)
    files = dir([dir_bootstrapci,'*',pair,'*.mat']);
    m = length(files);
    temp = NaN(n,nseed*B);
    
    if(obj == 'trend')
        ll = '1';
    elseif(strcmp(obj(1:2),'am'))
        ll = ['1+',obj(3)];
    elseif(strcmp(obj(1:2),'ph'))
       	obj = strsplit(obj,'ph');
        obj = strsplit(obj{2},'_');
        ll = ['1+',obj{2},'+',obj{1}];
    end  

    for j = 1:m
        load([dir_bootstrapci,files(j).name])
        temp(:,B*(j-1)+1:B*j) = eval(['Bout_',pair,'(:,',ll,',:)']);
    end
    
    keyboard()
end