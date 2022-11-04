function [meetsHardMode,feedback] = checkHardMode(guess,previousGuess,previousResult)
%CHECKHARDMODE - See if a guess meets the hard mode requirements of Wordle
% 
%   [meetsHardMode,feedback] = checkHardMode(guess,previousGuess,previousResult)

meetsHardMode = true;
feedback = '';
for i = 1:length(guess)
    if previousResult(i)==2 && previousGuess(i)~=guess(i)
        meetsHardMode = false;
        feedback = ['Guess must have ' previousGuess(i) ' in position ' num2str(i)];
        break;
    elseif previousResult(i)==1 && ~ismember(previousGuess(i),guess)
        meetsHardMode = false;
        feedback = ['Guess must have ' previousGuess(i)];
        break
    end
end