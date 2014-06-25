[exptEndSndData, exptEndSndFreq] = wavread('expt.end.wav');                     % setup end of expt run sound

practice_run_02.run();
run_04.run();
run_05.run();
run_06.run();


% Display RUN FINISHED instructions
bg_color    = 'white';
font_name   = 'Helvetica';                  % font name for all instructions
font_size   = 24;                           % font size for all instructions
font_color  = 'black';                      % fonct color for all instructions
font_wrap   = 45;

win_ptr          = setupScreen(color2RGB(bg_color));                            % setup screen
Screen('TextFont', win_ptr, font_name);                                         % setup text font
Screen('TextSize', win_ptr, font_size);                                         % setup text size
end_instructions = sprintf('Block 2 of 3 finished.\n\n Please see experimentor.');              
DrawFormattedText( win_ptr, end_instructions, 'center', 'center',color2RGB(font_color),font_wrap);
Screen('Flip'    , win_ptr);                                                    % draw buffer to monitor
KbWait();                                                                       % wait for keyboard press
ShowCursor;
Screen('CloseAll');                                                             % close psychtoolbox screen
 
soundsc(exptEndSndData, exptEndSndFreq);                                      % play sound
  