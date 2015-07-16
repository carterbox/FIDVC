function [converged01, SSE1 , sSize1, sSpacing1] = checkConvergenceSSD(I,SSE,sSize,sSpacing,convergenceCrit)
% [converged01, SSD1 , sSize1, sSpacing1] =
% checkConvergenceSSD(I,SSD,sSize,sSpacing,convergenceCrit) checks the
% convergence of the IDVC. The convergence is based on the sum of squared
% error (SSE) similarity metric between the undeformed and deformed 
% image. 
% 
% INPUTS
% -------------------------------------------------------------------------
%   I: cell containing the undeformed, I{1}, and deformed, I{2} 3-D images
%   SSE: array of SSD values for all iterations
%   sSize: interrogation window (subset) size for all iterations
%   sSpacing: interrogation window (subset) spacing for all iterations
%   convergenceCrit: Array containing convergence criteria for stopping the
%                    iterations.  [local, local, global] where local defines when
%                    to refine the sSize and/or sSpacing and global defines
%                    when to stop the iterations without refinement.
%
% OUTPUTS
% -------------------------------------------------------------------------
%   converged01: boolean, 1 = met convergence criteria for stopping, 0 =
%                has not met convergence criteria
%   SSE1: SSE for current iteration
%   sSize1: interrogation window (subset) size for the current iteration
%   sSpacing1: interrogation window (subset) spacing for the current 
%              iteration
%   
% NOTES
% -------------------------------------------------------------------------
% You are welcome to change the convergence method however you'd like. The
% default constants are based on empirical results.
% 
% If used please cite:
% Bar-Kochba E., Toyjanova J., Andrews E., Kim K., Franck C. (2014) A fast 
% iterative digital volume correlation algorithm for large deformations. 
% Experimental Mechanics. doi: 10.1007/s11340-014-9874-2

I{1}(isnan(I{1})) = 0;
I{2}(isnan(I{2})) = 0;

I{1} = I{1}(:); I{2} = I{2}(:);

switch 1
    case 1 % SSD (see eq. 12)
        N = numel(I{1});
        err = sqrt(sum((I{1}-I{2}).^2)/N);
        sig(1) = sqrt(sum((I{1}-mean(I{1})).^2)/N);
        sig(2) = sqrt(sum((I{2}-mean(I{2})).^2)/N);
        SSE1 = err/mean([sig(1),sig(2)]);
    case 2 % ZNSSD
        mu(1) = mean(I{1});
        mu(2) = mean(I{2});
        sig(1) = sqrt(sum((I{1}-mu(1)).^2));
        sig(2) = sqrt(sum((I{2}-mu(2)).^2));
        SSE1 = sum(((I{1}-mu(1))./sig(1) - (I{2}-mu(2))./sig(2)).^2);
end

SSE(end + 1) = SSE1;

% Set default values.
sSize0 = sSize(end,:); sSpacing0 = sSpacing(end,:);
sSize1 = sSize(end,:); sSpacing1 = sSpacing(end,:);
iteration = size(sSize,1);
dSSE = nan;
converged01 = false;

% Local threshold criteria
if iteration > 1 % Skip before first displacement estimation.
    sSize1 = sSize0/2; % window size refinement (Should be int division.) 
    
    % Ensure that all subset sizes are at minimum 32 voxels in length.
    sSize1(sSize1 < 32) = 32; 
    
    % Window spacing refinement. Only do if the sSpacing > 8 voxels
    if (sSpacing0 > 8), sSpacing1 = sSize1/2; end 
    
    % Condition: all spacings = 16
    if prod(single(sSpacing1 == 16),2)
       % Convert to single for backwards compatibility.
       
        if iteration > 2
            dSSE = diff(SSE(1:iteration)); % calculate difference
            dSSE = dSSE/dSSE(1); % normalize difference
             
            % If dSSE meets first convergence criteria then refine spacing
            % to the minimum value, 8 voxels, and unrefine window size. 
            if dSSE(end) <= convergenceCrit(1)
                sSize1 = sSize0; sSpacing1 = [8 8 8]; 
            end
        end
        
    % Condition: all spacings are the minimum 8 voxels
    elseif  prod(single(sSpacing1 == 8))
        %idx = find(prod(single(sSpacing == 8),2)):iteration;
        
        if iteration > 2
            dSSE = diff(SSE(1:iteration));
            dSSE = dSSE/dSSE(1);
            
            % If dSSE meets first convergence criteria and spacing is the
            % mimumum, then convergence has been met. Stop all iterations.
            if dSSE(end) <= convergenceCrit(2) 
                sSize1 = sSize0; sSpacing1 = sSpacing0;
                converged01 = true;
            end
        end
    end
end

% Global threshold criteria
if SSE(end)/SSE(1) < convergenceCrit(3), converged01 = true; end

end