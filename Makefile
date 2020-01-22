SHELL=/bin/bash
DIR_GUARD=@mkdir -p $(@D)

SRC=en
TGT=de

all: plots

download/wmt19-submitted-data-v3-txt-minimal.tgz : 
	$(DIR_GUARD)
	curl 'http://ufallab.ms.mff.cuni.cz/~bojar/wmt19/wmt19-submitted-data-v3-txt-minimal.tgz' --output $@

# we remove online-B for gu-en as it has not been listed in the proceedings and later messes up correlation with HE.
download/wmt19-submitted-data-v3/txt/system-outputs/newstest2019 : download/wmt19-submitted-data-v3-txt-minimal.tgz
	$(DIR_GUARD)
	cd $(dir $<); tar -xzf $(notdir $<); 
	rm download/wmt19-submitted-data-v3/txt/system-outputs/newstest2019/gu-en/newstest2019.online-B.0.gu-en

download/wmt19-submitted-data-v3/txt/system-outputs/newstest2019/$(SRC)-$(TRG) : download/wmt19-submitted-data-v3/txt/system-outputs/newstest2019 

data/wmt19/$(SRC)-$(TGT) : download/wmt19-submitted-data-v3/txt/system-outputs/newstest2019/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf $^ $@

data/wmt19/$(SRC)-$(TGT)/newstest2019.HUMAN.$(SRC)-$(TGT) : download/wmt19-submitted-data-v3/txt/system-outputs/newstest2019 data/wmt19/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf download/wmt19-submitted-data-v3/txt/references/newstest2019-$(SRC)$(TGT)-ref.$(TGT) $@

results/wmt19.$(SRC)-$(TGT).mtld.txt : data/wmt19/$(SRC)-$(TGT) data/wmt19/$(SRC)-$(TGT)/newstest2019.HUMAN.$(SRC)-$(TGT)
	$(DIR_GUARD)
	for output in data/wmt19/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		cat $$output | perl scripts/mtld.pl $(TGT); \
	done | grep -v task | perl -pe 's/data\/wmt19\/$(SRC)-$(TGT)\/newstest2019.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt19.$(SRC)-$(TGT).ttr.txt : data/wmt19/$(SRC)-$(TGT) data/wmt19/$(SRC)-$(TGT)/newstest2019.HUMAN.$(SRC)-$(TGT)
	$(DIR_GUARD)
	for output in data/wmt19/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		cat $$output | perl scripts/ttr.pl $(TGT); \
	done | grep -v task | perl -pe 's/data\/wmt19\/$(SRC)-$(TGT)\/newstest2019.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt19.$(SRC)-$(TGT).%.scatter1: results/wmt19.$(SRC)-$(TGT).%.txt human-eval/ad-sys-ranking-$(SRC)-$(TGT)-z.csv
	paste <(sort -k1,1 results/wmt19.$(SRC)-$(TGT).$*.txt) <(sort -k5,5 human-eval/ad-sys-ranking-$(SRC)-$(TGT)-z.csv | grep -v task) -d ' ' | cut -f 1,2,4 -d ' ' > $@

results/wmt19.$(SRC)-$(TGT).%.scatter2: results/wmt19.$(SRC)-$(TGT).%.txt human-eval/ad-sys-ranking-$(SRC)-$(TGT)-z.csv
	paste <(sort -k1,1 results/wmt19.$(SRC)-$(TGT).$*.txt | grep -v HUMAN) <(sort -k5,5 human-eval/ad-sys-ranking-$(SRC)-$(TGT)-z.csv | grep -v task) -d ' ' | cut -f 1,2,4 -d ' ' > $@

results1.wmt19.$(SRC)-$(TGT): \
	results/wmt19.$(SRC)-$(TGT).mtld.txt \
	results/wmt19.$(SRC)-$(TGT).mtld.scatter1 \
	results/wmt19.$(SRC)-$(TGT).ttr.txt \
	results/wmt19.$(SRC)-$(TGT).ttr.scatter1

results2.wmt19.$(SRC)-$(TGT): \
	results/wmt19.$(SRC)-$(TGT).mtld.txt \
	results/wmt19.$(SRC)-$(TGT).mtld.scatter2 \
	results/wmt19.$(SRC)-$(TGT).ttr.txt \
	results/wmt19.$(SRC)-$(TGT).ttr.scatter2

clean:
	rm -rf download data results

onePairWithHE: results1.wmt19.$(SRC)-$(TGT)

onePairWithoutHE: results2.wmt19.$(SRC)-$(TGT)

allpairs: download/wmt19-submitted-data-v3/txt/system-outputs/newstest2019
	$(MAKE) onePairWithHE SRC=de TGT=en
	$(MAKE) onePairWithHE SRC=en TGT=cs
	$(MAKE) onePairWithHE SRC=en TGT=de
	$(MAKE) onePairWithHE SRC=en TGT=fi
	$(MAKE) onePairWithHE SRC=en TGT=gu
	$(MAKE) onePairWithHE SRC=en TGT=lt
	$(MAKE) onePairWithHE SRC=en TGT=ru
	$(MAKE) onePairWithHE SRC=en TGT=zh
	$(MAKE) onePairWithoutHE SRC=fi TGT=en
	$(MAKE) onePairWithoutHE SRC=gu TGT=en
	$(MAKE) onePairWithoutHE SRC=lt TGT=en
	$(MAKE) onePairWithoutHE SRC=ru TGT=en
	$(MAKE) onePairWithoutHE SRC=kk TGT=en
	$(MAKE) onePairWithoutHE SRC=zh TGT=en

results/fig1.mtld.png : allpairs
	python3 scripts/boxplot.py $@ results/wmt19.*.mtld.txt

results/fig1.ttr.png : allpairs
	python3 scripts/boxplot.py $@ results/wmt19.*.ttr.txt

results/fig2.ttr.png : allpairs
	python3 scripts/corplot.py $@ results/wmt19.*.ttr.scatter[12]

results/fig2.mtld.png : allpairs
	python3 scripts/corplot.py $@ results/wmt19.*.mtld.scatter[12]

#################################################################################################################################################################################
# Historic stuff over time

### WMT15 ####################################################################################

download/wmt15-submitted-data.tgz : 
	$(DIR_GUARD)
	curl 'http://www.statmt.org/wmt15/wmt15-submitted-data.tgz' --output $@

# we remove online-B for gu-en as it has not been listed in the proceedings and later messes up correlation with HE.
download/wmt15-submitted-data/txt/system-outputs/newstest2015 : download/wmt15-submitted-data.tgz
	$(DIR_GUARD)
	cd $(dir $<); tar -xzf $(notdir $<); 

download/wmt15-submitted-data/txt/system-outputs/newstest2015/$(SRC)-$(TGT) : download/wmt15-submitted-data/txt/system-outputs/newstest2015 

data/wmt15/$(SRC)-$(TGT) : download/wmt15-submitted-data/txt/system-outputs/newstest2015/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf $^ $@

data/wmt15/$(SRC)-$(TGT)/newstest2015.HUMAN.$(SRC)-$(TGT) : download/wmt15-submitted-data/txt/system-outputs/newstest2015 data/wmt15/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf download/wmt15-submitted-data/txt/references/newstest2015-$(SRC)$(TGT)-ref.$(TGT) $@

### WMT16 ####################################################################################

download/wmt16-submitted-data-v2.tgz : 
	$(DIR_GUARD)
	curl 'http://data.statmt.org/wmt16/translation-task/wmt16-submitted-data-v2.tgz' --output $@

# we remove online-B for gu-en as it has not been listed in the proceedings and later messes up correlation with HE.
download/wmt16-submitted-data/txt/system-outputs/newstest2016 : download/wmt16-submitted-data-v2.tgz
	$(DIR_GUARD)
	cd $(dir $<); tar -xzf $(notdir $<); 

download/wmt16-submitted-data/txt/system-outputs/newstest2016/$(SRC)-$(TGT) : download/wmt16-submitted-data/txt/system-outputs/newstest2016

data/wmt16/$(SRC)-$(TGT) : download/wmt16-submitted-data/txt/system-outputs/newstest2016/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf $^ $@

data/wmt16/$(SRC)-$(TGT)/newstest2016.HUMAN.$(SRC)-$(TGT) : download/wmt16-submitted-data/txt/system-outputs/newstest2016 data/wmt16/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf download/wmt16-submitted-data/txt/references/newstest2016-$(SRC)$(TGT)-ref.$(TGT) $@

### WMT17 ####################################################################################

download/wmt17-submitted-data-v1.0.tgz : 
	$(DIR_GUARD)
	curl 'http://data.statmt.org/wmt17/translation-task/wmt17-submitted-data-v1.0.tgz' --output $@

# we remove online-B for gu-en as it has not been listed in the proceedings and later messes up correlation with HE.
download/wmt17-submitted-data/txt/system-outputs/newstest2017 : download/wmt17-submitted-data-v1.0.tgz
	$(DIR_GUARD)
	cd $(dir $<); tar -xzf $(notdir $<); 

download/wmt17-submitted-data/txt/system-outputs/newstest2017/$(SRC)-$(TGT) : download/wmt17-submitted-data/txt/system-outputs/newstest2017

data/wmt17/$(SRC)-$(TGT) : download/wmt17-submitted-data/txt/system-outputs/newstest2017/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf $^ $@

data/wmt17/$(SRC)-$(TGT)/newstest2017.HUMAN.$(SRC)-$(TGT) : download/wmt17-submitted-data/txt/system-outputs/newstest2017 data/wmt17/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf download/wmt17-submitted-data/txt/references/newstest2017-$(SRC)$(TGT)-ref.$(TGT) $@

### WMT18 ####################################################################################

download/wmt18-submitted-data-v1.0.1.tgz : 
	$(DIR_GUARD)
	curl 'http://data.statmt.org/wmt18/translation-task/wmt18-submitted-data-v1.0.1.tgz' --output $@

# we remove online-B for gu-en as it has not been listed in the proceedings and later messes up correlation with HE.
download/wmt18-submitted-data/txt/system-outputs/newstest2018 : download/wmt18-submitted-data-v1.0.1.tgz
	$(DIR_GUARD)
	cd $(dir $<); tar -xzf $(notdir $<); 

download/wmt18-submitted-data/txt/system-outputs/newstest2018/$(SRC)-$(TGT) : download/wmt18-submitted-data/txt/system-outputs/newstest2018

data/wmt18/$(SRC)-$(TGT) : download/wmt18-submitted-data/txt/system-outputs/newstest2018/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf $^ $@

data/wmt18/$(SRC)-$(TGT)/newstest2018.HUMAN.$(SRC)-$(TGT) : download/wmt18-submitted-data/txt/system-outputs/newstest2018 data/wmt18/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf download/wmt18-submitted-data/txt/references/newstest2018-$(SRC)$(TGT)-ref.$(TGT) $@

#############################################################################################

results/wmt15.$(SRC)-$(TGT).ttr.txt : splits/wmt15.$(SRC)$(TGT).split data/wmt15/$(SRC)-$(TGT) data/wmt15/$(SRC)-$(TGT)/newstest2015.HUMAN.$(SRC)-$(TGT)
	$(DIR_GUARD)
	for output in data/wmt15/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt15.$(SRC)$(TGT).split <(cat $$output) | grep '^True' | cut -f 2 | perl scripts/ttr.pl $(TGT); \
	done | perl -pe 's/data\/wmt15\/$(SRC)-$(TGT)\/newstest2015.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt16.$(SRC)-$(TGT).ttr.txt : splits/wmt16.$(SRC)$(TGT).split data/wmt16/$(SRC)-$(TGT) data/wmt16/$(SRC)-$(TGT)/newstest2016.HUMAN.$(SRC)-$(TGT)
	$(DIR_GUARD)
	for output in data/wmt16/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt16.$(SRC)$(TGT).split <(cat $$output) | grep '^True' | cut -f 2 | perl scripts/ttr.pl $(TGT); \
	done | perl -pe 's/data\/wmt16\/$(SRC)-$(TGT)\/newstest2016.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt17.$(SRC)-$(TGT).ttr.txt : splits/wmt17.$(SRC)$(TGT).split data/wmt17/$(SRC)-$(TGT) data/wmt17/$(SRC)-$(TGT)/newstest2017.HUMAN.$(SRC)-$(TGT)
	$(DIR_GUARD)
	for output in data/wmt17/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt17.$(SRC)$(TGT).split <(cat $$output) | grep '^True' | cut -f 2 | perl scripts/ttr.pl $(TGT); \
	done | perl -pe 's/data\/wmt17\/$(SRC)-$(TGT)\/newstest2017.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt18.$(SRC)-$(TGT).ttr.txt : splits/wmt18.$(SRC)$(TGT).split data/wmt18/$(SRC)-$(TGT) data/wmt18/$(SRC)-$(TGT)/newstest2018.HUMAN.$(SRC)-$(TGT)
	$(DIR_GUARD)
	for output in data/wmt18/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt18.$(SRC)$(TGT).split <(cat $$output) | grep '^True' | cut -f 2 | perl scripts/ttr.pl $(TGT); \
	done | perl -pe 's/data\/wmt18\/$(SRC)-$(TGT)\/newstest2018.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

#############################################################################################
# in wrong direction, reference is native text, via grep -v

results/wmt15.$(SRC)-$(TGT).ttr.inv.txt : splits/wmt15.$(SRC)$(TGT).split data/wmt15/$(SRC)-$(TGT) data/wmt15/$(SRC)-$(TGT)/newstest2015.HUMAN.$(SRC)-$(TGT)
	$(DIR_GUARD)
	for output in data/wmt15/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt15.$(SRC)$(TGT).split <(cat $$output) | grep -v '^True' | cut -f 2 | perl scripts/ttr.pl $(TGT); \
	done | perl -pe 's/data\/wmt15\/$(SRC)-$(TGT)\/newstest2015.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt16.$(SRC)-$(TGT).ttr.inv.txt : splits/wmt16.$(SRC)$(TGT).split data/wmt16/$(SRC)-$(TGT) data/wmt16/$(SRC)-$(TGT)/newstest2016.HUMAN.$(SRC)-$(TGT)
	$(DIR_GUARD)
	for output in data/wmt16/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt16.$(SRC)$(TGT).split <(cat $$output) | grep -v '^True' | cut -f 2 | perl scripts/ttr.pl $(TGT); \
	done | perl -pe 's/data\/wmt16\/$(SRC)-$(TGT)\/newstest2016.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt17.$(SRC)-$(TGT).ttr.inv.txt : splits/wmt17.$(SRC)$(TGT).split data/wmt17/$(SRC)-$(TGT) data/wmt17/$(SRC)-$(TGT)/newstest2017.HUMAN.$(SRC)-$(TGT)
	$(DIR_GUARD)
	for output in data/wmt17/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt17.$(SRC)$(TGT).split <(cat $$output) | grep -v '^True' | cut -f 2 | perl scripts/ttr.pl $(TGT); \
	done | perl -pe 's/data\/wmt17\/$(SRC)-$(TGT)\/newstest2017.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt18.$(SRC)-$(TGT).ttr.inv.txt : splits/wmt18.$(SRC)$(TGT).split data/wmt18/$(SRC)-$(TGT) data/wmt18/$(SRC)-$(TGT)/newstest2018.HUMAN.$(SRC)-$(TGT)
	$(DIR_GUARD)
	for output in data/wmt18/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt18.$(SRC)$(TGT).split <(cat $$output) | grep -v '^True' | cut -f 2 | perl scripts/ttr.pl $(TGT); \
	done | perl -pe 's/data\/wmt18\/$(SRC)-$(TGT)\/newstest2018.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@


results.over.time: \
	results/wmt15.$(SRC)-$(TGT).ttr.txt \
	results/wmt16.$(SRC)-$(TGT).ttr.txt \
	results/wmt17.$(SRC)-$(TGT).ttr.txt \
	results/wmt18.$(SRC)-$(TGT).ttr.txt \
	results/wmt15.$(SRC)-$(TGT).ttr.inv.txt \
	results/wmt16.$(SRC)-$(TGT).ttr.inv.txt \
	results/wmt17.$(SRC)-$(TGT).ttr.inv.txt \
	results/wmt18.$(SRC)-$(TGT).ttr.inv.txt

results/fig3.ttr.png : allpairs results.over.time
	python3 scripts/boxplot.time.py $@ results/wmt1[56789].$(SRC)-$(TGT).ttr.txt

results/fig3.ttr.inv.png : allpairs results.over.time
	python3 scripts/boxplot.time.py $@ results/wmt1[5678].$(SRC)-$(TGT).ttr.inv.txt

#####################################################################################################

plots: \
    results/fig1.ttr.png results/fig1.mtld.png \
	results/fig2.ttr.png results/fig2.mtld.png \
	results/fig3.ttr.png results/fig3.ttr.inv.png