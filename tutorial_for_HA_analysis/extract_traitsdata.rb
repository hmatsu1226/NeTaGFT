#!/usr/bin/ruby

fcl = open(ARGV[0], "r")
ffa = open(ARGV[1], "r")
fmeta = open(ARGV[2], "r")
fcountry = open(ARGV[3], "r")
fout1 = open(ARGV[4], "w")
fout2 = open(ARGV[5], "w")
seqnum = ARGV[6].to_i

print(seqnum)

#Create a hash table to convert country names into regions
country_to_region = Hash.new()
fcountry.gets
while line=fcountry.gets
	tmp = line.split(",")
	country_to_region[tmp[0]] = tmp[5]
end

#Create a hash table to map the accession numbers of the original sequences to their clusters in cd-hit
#Create another hash table to record whether they are representative sequences or not.
accession_to_cluster = Hash.new()
is_representative = Hash.new()
cluster_size = Array.new(seqnum, 0)
cluster_id = -1
while line=fcl.gets
	if line[0] == ">"
		cluster_id = line.split(" ")[1].to_i
	else
		tmp = line.split("\t")[1]
		tmp = tmp.split(">")[1]
		accession = tmp.split("\.")[0]
		
		accession_to_cluster[accession] = cluster_id
		cluster_size[cluster_id] += 1

		tmp = line.split(" ")[3]
		if tmp == "*"
			is_representative[accession] = 1
		else
			is_representative[accession] = 0
		end
	end
end


#Retrieve the metadata for the following information:
#H1-H13,N1-N11,host(Avian,Swine,Human),Africa,Americas,Asia,Europe,Oceania,year
out = ""
for i in 1..13
	out += ",H#{i}"
end
for i in 1..11
	out += ",N#{i}"
end
out += ",Avian,Swine,Human,Africa,Americas,Asia,Europe,Oceania,year"
fout1.puts(out)

data = Array.new(seqnum)
for i in 0..(seqnum-1)
	data[i] = Array.new(13+11+3+5+1,0)
end

line = fmeta.gets
while line=fmeta.gets
	tmp = line.split(",")
	accession = tmp[0][1,tmp[0].length()-2]
	cluster_id = accession_to_cluster[accession]

	if cluster_id == nil
		next
	end

	host = tmp[2]
	serotype = tmp[4]

	#"mixed,"の場合、カンマが一つ多いので一つ分ずらすため
	flag = 0
	if serotype == "\"mixed"
		flag = 1
	end

	country = tmp[5+flag].split("\"")[1]

	htype = serotype.split("N")[0].split("H")[1]
	for i in 1..13
		if htype == "#{i}"
			data[cluster_id][i-1] += 1
		end
	end

	ntype = serotype.split("N")[1]
	if !(ntype.nil?)
		ntype = ntype.split("\"")[0]
	end
	
	for i in 1..11
		if ntype == "#{i}"
			data[cluster_id][i+13-1] += 1
		end
	end

	if host == "\"Avian\""
		data[cluster_id][1+13+11-1] += 1
	elsif host == "\"Swine\""
		data[cluster_id][2+13+11-1] += 1
	elsif host == "\"Human\""
		data[cluster_id][3+13+11-1] += 1
	end

	region = country_to_region[country]
	if region == nil
		#puts(country)
	elsif region == "Africa"
		data[cluster_id][1+13+11+3-1] += 1
	elsif region == "Americas"
		data[cluster_id][2+13+11+3-1] += 1
	elsif region == "Asia"
		data[cluster_id][3+13+11+3-1] += 1
	elsif region == "Europe"
		data[cluster_id][4+13+11+3-1] += 1
	elsif region == "Oceania"
		data[cluster_id][5+13+11+3-1] += 1
	else
		puts("unassigned country : #{country} #{region}")
	end

	#year of representative seq
	if is_representative[accession] == 1
		#date
		date = tmp[7+flag].split("\"")[1]
		#puts(date)
		if date == nil
			next
		end
		year = date.split("\/")[0].to_i

		data[cluster_id][1+13+11+3+5-1] = year
	end
end

#save traits table
for i in 0..(seqnum-1)
	out = "#{i}"
	for j in 0..(13+11+3+5+1-1)
		out += ",#{data[i][j]}"
	end
	fout1.puts(out)
end

#save represent seqence accession name and corresponding cluster id table
while line = ffa.gets
	if line[0] == ">"
		tmp = line.split(" ")[0]
		accession = tmp[1,tmp.length()]
		fout2.puts("#{accession}\t#{accession_to_cluster[accession]}")
	end
end
