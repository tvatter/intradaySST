function paramGrid_bootstrapci(seed_min, seed_max, B)
  
    system(['Rscript utils/paramGrid_bootstrapci.R ', num2str(seed_min), ' ',num2str(seed_max), ' ', num2str(B)])

end