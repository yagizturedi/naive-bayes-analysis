% Yağız Türedi

%% Preparation

clear
clc
Table = xlsread("UniversalBank.xls",2);
Table(:,[1,5])=[];
TEMP=Table(:,8);
Table(:,8)=Table(:,12);
Table(:,12)=TEMP;

%% Binning The Variables

for BinNumber=1:7

BinColumns=[1,2,3,5,7];
BinLength=length(Table)/BinNumber;
remainder=rem(length(Table),BinLength);

for i=1:length(BinColumns)
    M=sort(Table(:,BinColumns(i)));
    for m=BinNumber:-1:1
        BIN(m)=M(m*BinNumber+remainder);
        if remainder>0
            remainder=remainder-1;
        end
    end
    for t=1:length(Table)
        r=0;
        n=BinNumber;
        while n~=0
            if Table(t,BinColumns(i))<=BIN(n)
                r=n;
            end
            Table(t,BinColumns(i))=r;
            n=n-1;
        end
    end
end

for runnumber=1:5
%% Partitioning The Dataset

x=randperm(length(Table),round(length(Table)/5,0));
Validation=zeros(length(x),11);
ValCC=zeros(length(x),1);
for i=1:length(x)
    Validation(i,[1:11])=Table(x(i),[1:11]);
    ValCC(i)=Table(x(i),12);
end

Training=zeros(length(Table)-length(x),11);
TrCC=zeros(length(Table)-length(x),1);
n=1;

for i=1:length(Table)
    if ismember(i,x)
        continue;
    else
        Training(n,[1:11])=Table(i,[1:11]);
        TrCC(n)=Table(i,12);
        n=n+1;
    end
end


%% PART I - a) Writing a Naive-Bayes Algorithm

CountOfCC(1)=sum(TrCC);     % Number of People With Credit Cards in Training Data
CountOfCC(2)=length(TrCC)-sum(TrCC);    % Number of People Without Credit Cards in Training Data
P(1)=CountOfCC(1)/length(TrCC);
P(2)=CountOfCC(2)/length(TrCC);
prediction=zeros(1,length(Validation));

for i=1:length(Validation)
    
    count=0;
    count1=0;
    count0=0;
    
    for j=1:length(Training)
        if Validation(i,:)==Training(j,:)
            count=count+1;
            if TrCC(j)==1
                count1=count1+1;
            elseif TrCC(j)==0
                count0=count0+1;
            end
        end
    end
    
    Probability(1)=(count1/CountOfCC(1))*P(1)/(count/length(TrCC));
    Probability(2)=(count0/CountOfCC(2))*P(2)/(count/length(TrCC));
    
    if Probability(1)>Probability(2)
        prediction(i)=1;
    else
        prediction(i)=0;
    end
end

ErrorRate=VectorDiff(prediction,ValCC);

if P(1)>P(2)
    NaivePred=ones(1,length(Validation));
else
    NaivePred=zeros(1,length(Validation));
end

NaiveError=VectorDiff(NaivePred,ValCC);

ErrorRecorder(1,runnumber,BinNumber)=ErrorRate;
ErrorRecorder(2,runnumber,BinNumber)=NaiveError;
end
end
