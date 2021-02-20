# recursive-dumper
Recursively dump all database and tables. Optionally push the .sql files to a git repo to be used as schema dumps or versioned test data.

<pre><font color="#8AE234"><b>➜  </b></font><font color="#34E2E2"><b>database-dumper</b></font> <font color="#729FCF"><b>git:(</b></font><font color="#EF2929"><b>master</b></font><font color="#729FCF"><b>)</b></font> <font color="#4E9A06">./dump.sh</font> --help                       
command [options]                                                                    
Commands:                                                                            
   dump [options]  recusively dump one file for each database and one for each table 
   import-db --repo [git repo] --database [database] --source [source]  [options]    
   import-table --repo [repo] --database [dest db] --source [source db] --table [table] [opts]
Options:                                                                             
  -h, --help            # print help menu and exit                                   
      --hash [hash]     # checkout a commit hash                                     
  -r, --repo            # git repo (requires existing --initialized-- git repo)      
  -gz, --tar            # compress indevidual sql files. Does not work with git      
  -m, --message [$NOW]  # commit message [OPTIONAL]                                  
  -R, --remote [origin] # commit remote [OPTIONAL]                                   
  -b, --branch          # push to this git branch                                    
  -o, --out-dir [$(pwd)/mysqldump_${NOW}] # output directory (where to dump the data)
  -h, --host [localhost] # mysql host                                                
      --port [3306]      # mysql port                                                
  -u, --user [root]     # mysql user                                                 
  -p, --password required # mysql password (leave empty                              
                            to enter interactively and avoid passing in clear text   
                            through shell)                                           
  -v, --verbose         # show output    </pre>
