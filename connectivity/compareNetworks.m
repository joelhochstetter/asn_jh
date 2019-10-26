%% Import and calcualate statistics
%folder = '/import/silo2/joelh/ChangeNetworks/VaryWidth1/'; %This includes networks where number of networks is small 

folder = '/suphys/joelh/Documents/MATLAB/atomic-switch-network-1.3-beta/atomic-switch-network-1.3-beta/asn/connectivity/connectivity_data/exp/';
files = dir(strcat(folder, '*00.mat'));
n = numel(files);
av_nd  = zeros(n,1);
std_nd = zeros(n,1);
num_j  = zeros(n,1);
diamet = zeros(n,1);
num_w  = zeros(n,1);
char_p = zeros(n,1);
dens   = zeros(n,1);
c_disp = zeros(n,1);
sd_dis = zeros(n,1); %distance from source to drain

%{
i = 1;
for file = files'
    ff = strcat(file.folder,'/',file.name);
    t = load(ff);
    c_disp(i) = t.centroid_dispersion;
    i = i + 1;
end

[sortedX, sortIndex] = sort(c_disp);
files = files(sortIndex);
%}

i = 1;
for file = files'
    ff = strcat(file.folder,'/',file.name);
    t = load(ff);
    av_nd(i)  = t.avg_nd;
    std_nd(i) = t.std_nd;
    num_j(i)  = t.number_of_junctions;
    diamet(i) = t.diameter;
    num_w(i)  = t.number_of_wires;
    char_p(i) = t.charpath;
    dens(i)   = t.density;
    c_disp(i) = t.centroid_dispersion;
    sd_dis(i) = max(max(graphallshortestpaths(sparse(double(t.adj_matrix)))));
    i = i + 1;
end

%% Plot stuff
figure
plot(av_nd, sd_dis)
xlabel  'Average degree'
ylabel 'Source drain distance'


figure
plot(c_disp,num_w)
ylabel 'Number of wires in network'
yyaxis right
plot(c_disp,av_nd)
ylabel 'Average degree'
xlabel 'Centroid dispersion'
