function get_simuldata(dir_simul,pair,obj,n,nseed,B,options)

    filesfff = dir([dir_simul,'*fff*',pair,'*.mat']);
    filessst = dir([dir_simul,'*sst*',pair,'*.mat']);
    m = length(filesfff);

    nn = [obj,'simul_',pair]; 
    nseed = nseed;
    n = n;
    B = B;
    
    for k = 1:3
       eval([nn,'_fff',num2str(k),' = NaN(n,nseed*B,5);']);
       eval([nn,'_sst',num2str(k),' = NaN(n,nseed*B,5);']);
    end
    
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
        load([dir_simul,filesfff(j).name])
        for k = 1:3
            eval([nn,'_fff',num2str(k),'(:,B*(j-1)+1:B*j,:) = Bout',num2str(k),'(:,',ll,',:,:);']);
        end
        load([dir_simul,filessst(j).name])
        for k = 1:3
            eval([nn,'_sst',num2str(k),'(:,B*(j-1)+1:B*j,:) = Bout',num2str(k),'(:,',ll,',:,:);']);
        end
    end

    for k = 1:3
       eval(['save  -v7.3 temp/',nn,'_sst',num2str(k),'.mat ',nn,'_sst',num2str(k)]);
       eval(['save  -v7.3 temp/',nn,'_fff',num2str(k),'.mat ',nn,'_fff',num2str(k)]);
    end
end