function [list_dyn_ann, list_dyn_caut, dyn_ann, dyn_caut] = get_pwadyn2(u)
% Given parameters in the dynamics, control inputs and sampling time,
% return the lists of dynamics for annoying driver and cautious driver for
% each input.

%  INPUTS: u --- list of inputs [u1 u2 u3 u4 ... u_n], ith column is the
%                input at time i;
%          dt --- sampling time
%          param --- the parameters in the system equations. (see the
%          documentations of the model used in the intention estimation.
% OUTPUTS: list_dyn_ann --- cell of annoying dynamics 
%                           at t0, t1, t2, ..., t_n
%          list_dyn_caut --- cell of cautious dynamics 
%                            at t0, t1, t2, ..., t_n
%          dyn_ann --- the dynamics of annoying driver with bounded inputs
%          dyn_caut --- the dynamics of the cautious driver with bounded
%                       inputs

list_dyn_ann = cell(size(u,2),1);
list_dyn_caut = cell(size(u,2),1);

for i = 1:size(u,2)
    list_dyn_ann{i} = create_pwa_passing_model('annoying',u(:,i));
end

end