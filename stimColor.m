classdef stimColor
%STIMCOLOR Summary of this class goes here
%   Detailed explanation goes here

   properties
       
       name;
       rgb_matrix;

       testNum;
       
   end

   methods
       
       
      
       function test(obj)


                keyIsDown = false;
                counter = 1;
                
                while(~keyIsDown)
                    
                    display(obj.name);
                    obj.testNum(counter) = counter;
                    
                    
                    
                    keyIsDown   = KbCheck();
                    counter     = counter+1;
                    
                    save('testSave', 'obj');
                    
                end
                    
            
       end % show function
       
       
       
   end
   end 

   
