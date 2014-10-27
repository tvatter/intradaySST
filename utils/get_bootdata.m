function get_bootdata(dir_bootstrapci,pair,obj,n,nseed,B,options)

    files = dir([dir_bootstrapci,'*',pair,'*.mat']);
    m = length(files);
    nn = [obj,'boot_',pair]; 
    nseed = nseed;
    n = n;
    B = B;
    eval([nn,' = NaN(n,nseed*B);']);
        
    if(strcmp(obj(1),'T'))
        ll = '1';
    elseif(strcmp(obj(1:2),'am'))
        ll = strsplit(obj,'am');
        ll = ['1+',ll{2}];
    elseif(strcmp(obj(1:2),'ph'))
        ll = strsplit(obj,'ph');
        ll = ['1+',num2str(options.season.sst.ncomp),'+',ll{2}];
    end  
    
    for j = 1:m
        load([dir_bootstrapci,files(j).name])
        eval([nn,'(:,B*(j-1)+1:B*j) = Bout_',pair,'(:,',ll,',:);']);
    end

    eval(['save  -v7.3 temp/',nn,'.mat ',nn]);

end