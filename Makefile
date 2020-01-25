SHELL=/bin/bash
DIR_GUARD=@mkdir -p $(@D)

SRC=de
TGT=en

.PHONY: clean

all: plots

download/wmt19-submitted-data-v3-txt-minimal.tgz : 
	$(DIR_GUARD)
	curl 'http://ufallab.ms.mff.cuni.cz/~bojar/wmt19/wmt19-submitted-data-v3-txt-minimal.tgz' --output $@

# we remove online-B for gu-en as it has not been listed in the proceedings and later messes up correlation with HE.
download/wmt19-submitted-data-v3/done : download/wmt19-submitted-data-v3-txt-minimal.tgz
	cd $(dir $<); tar -xzf $(notdir $<); 
	rm download/wmt19-submitted-data-v3/txt/system-outputs/newstest2019/gu-en/newstest2019.online-B.0.gu-en
	touch $@

data/wmt19/$(SRC)-$(TGT) : download/wmt19-submitted-data-v3/done
	$(DIR_GUARD)
	cp -rf download/wmt19-submitted-data-v3/txt/system-outputs/newstest2019/$(SRC)-$(TGT) $@

data/wmt19/$(SRC)-$(TGT)/newstest2019.HUMAN.$(SRC)-$(TGT) : download/wmt19-submitted-data-v3/done data/wmt19/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf download/wmt19-submitted-data-v3/txt/references/newstest2019-$(SRC)$(TGT)-ref.$(TGT) $@

results/wmt19.$(SRC)-$(TGT).mtld.txt : data/wmt19/$(SRC)-$(TGT) data/wmt19/$(SRC)-$(TGT)/newstest2019.HUMAN.$(SRC)-$(TGT)
	$(DIR_GUARD)
	for output in data/wmt19/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		cat $$output | perl scripts/mtld.pl $(TGT) counts/news.en.counts download/wmt19-submitted-data-v3/txt/sources/newstest2019-$(SRC)$(TGT)-src.$(SRC) ; \
	done | grep -v task | perl -pe 's/data\/wmt19\/$(SRC)-$(TGT)\/newstest2019.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt19.$(SRC)-$(TGT).ttr.txt : data/wmt19/$(SRC)-$(TGT) data/wmt19/$(SRC)-$(TGT)/newstest2019.HUMAN.$(SRC)-$(TGT)
	$(DIR_GUARD)
	for output in data/wmt19/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		cat $$output | perl scripts/ttr.pl $(TGT) counts/news.en.counts download/wmt19-submitted-data-v3/txt/sources/newstest2019-$(SRC)$(TGT)-src.$(SRC) ; \
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

allpairs: \
	onePairWithHE_SRC_de_TGT_en \
	onePairWithHE_SRC_en_TGT_cs \
	onePairWithHE_SRC_en_TGT_de \
	onePairWithHE_SRC_en_TGT_fi \
	onePairWithHE_SRC_en_TGT_gu \
	onePairWithHE_SRC_en_TGT_lt \
	onePairWithHE_SRC_en_TGT_ru \
	onePairWithHE_SRC_en_TGT_zh \
	onePairWithoutHE_SRC_fi_TGT_en \
	onePairWithoutHE_SRC_gu_TGT_en \
	onePairWithoutHE_SRC_lt_TGT_en \
	onePairWithoutHE_SRC_ru_TGT_en \
	onePairWithoutHE_SRC_kk_TGT_en \
	onePairWithoutHE_SRC_zh_TGT_en

onePairWithHE_SRC_de_TGT_en: download/wmt19-submitted-data-v3/done
	$(MAKE) onePairWithHE SRC=de TGT=en

onePairWithHE_SRC_en_TGT_cs: download/wmt19-submitted-data-v3/done
	$(MAKE) onePairWithHE SRC=en TGT=cs

onePairWithHE_SRC_en_TGT_de: download/wmt19-submitted-data-v3/done
	$(MAKE) onePairWithHE SRC=en TGT=de

onePairWithHE_SRC_en_TGT_fi: download/wmt19-submitted-data-v3/done
	$(MAKE) onePairWithHE SRC=en TGT=fi

onePairWithHE_SRC_en_TGT_gu: download/wmt19-submitted-data-v3/done
	$(MAKE) onePairWithHE SRC=en TGT=gu

onePairWithHE_SRC_en_TGT_lt: download/wmt19-submitted-data-v3/done
	$(MAKE) onePairWithHE SRC=en TGT=lt

onePairWithHE_SRC_en_TGT_ru: download/wmt19-submitted-data-v3/done
	$(MAKE) onePairWithHE SRC=en TGT=ru

onePairWithHE_SRC_en_TGT_zh: download/wmt19-submitted-data-v3/done
	$(MAKE) onePairWithHE SRC=en TGT=zh

onePairWithoutHE_SRC_fi_TGT_en: download/wmt19-submitted-data-v3/done
	$(MAKE) onePairWithoutHE SRC=fi TGT=en

onePairWithoutHE_SRC_gu_TGT_en: download/wmt19-submitted-data-v3/done
	$(MAKE) onePairWithoutHE SRC=gu TGT=en

onePairWithoutHE_SRC_lt_TGT_en: download/wmt19-submitted-data-v3/done
	$(MAKE) onePairWithoutHE SRC=lt TGT=en

onePairWithoutHE_SRC_ru_TGT_en: download/wmt19-submitted-data-v3/done
	$(MAKE) onePairWithoutHE SRC=ru TGT=en

onePairWithoutHE_SRC_kk_TGT_en: download/wmt19-submitted-data-v3/done
	$(MAKE) onePairWithoutHE SRC=kk TGT=en

onePairWithoutHE_SRC_zh_TGT_en: download/wmt19-submitted-data-v3/done
	$(MAKE) onePairWithoutHE SRC=zh TGT=en

results/fig1.mtld.png : allpairs
	python3 scripts/boxplot.py $@ results/wmt19.*-en.mtld.txt results/wmt19.en-*.mtld.txt 

results/fig1.ttr.png : allpairs
	python3 scripts/boxplot.py $@ results/wmt19.*-en.ttr.txt results/wmt19.en-*.ttr.txt

results/fig2.ttr.png : allpairs
	python3 scripts/corplot.py $@ results/wmt19.*-en.ttr.scatter[12] results/wmt19.en-*.ttr.scatter[12]

results/fig2.mtld.png : allpairs
	python3 scripts/corplot.py $@ results/wmt19.*-en.mtld.scatter[12] results/wmt19.en-*.mtld.scatter[12]

#################################################################################################################################################################################
# Historic stuff over time

### WMT15 ####################################################################################

download/wmt15-submitted-data.tgz : 
	$(DIR_GUARD)
	curl 'http://www.statmt.org/wmt15/wmt15-submitted-data.tgz' --output $@

# we remove online-B for gu-en as it has not been listed in the proceedings and later messes up correlation with HE.
download/wmt15-submitted-data/done : download/wmt15-submitted-data.tgz
	$(DIR_GUARD)
	cd $(dir $<); tar -xzf $(notdir $<); 
	touch $@

data/wmt15/$(SRC)-$(TGT) : download/wmt15-submitted-data/done
	$(DIR_GUARD)
	cp -rf download/wmt15-submitted-data/txt/system-outputs/newstest2015/$(SRC)-$(TGT) $@

data/wmt15/$(SRC)-$(TGT)/newstest2015.HUMAN.$(SRC)-$(TGT) : download/wmt15-submitted-data/done data/wmt15/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf download/wmt15-submitted-data/txt/references/newstest2015-$(SRC)$(TGT)-ref.$(TGT) $@

### WMT16 ####################################################################################

download/wmt16-submitted-data-v2.tgz : 
	$(DIR_GUARD)
	curl 'http://data.statmt.org/wmt16/translation-task/wmt16-submitted-data-v2.tgz' --output $@

# we remove online-B for gu-en as it has not been listed in the proceedings and later messes up correlation with HE.
download/wmt16-submitted-data/done : download/wmt16-submitted-data-v2.tgz
	$(DIR_GUARD)
	cd $(dir $<); tar -xzf $(notdir $<); 
	touch $@

data/wmt16/$(SRC)-$(TGT) : download/wmt16-submitted-data/done
	$(DIR_GUARD)
	cp -rf download/wmt16-submitted-data/txt/system-outputs/newstest2016/$(SRC)-$(TGT) $@

data/wmt16/$(SRC)-$(TGT)/newstest2016.HUMAN.$(SRC)-$(TGT) : download/wmt16-submitted-data/done data/wmt16/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf download/wmt16-submitted-data/txt/references/newstest2016-$(SRC)$(TGT)-ref.$(TGT) $@

### WMT17 ####################################################################################

download/wmt17-submitted-data-v1.0.tgz : 
	$(DIR_GUARD)
	curl 'http://data.statmt.org/wmt17/translation-task/wmt17-submitted-data-v1.0.tgz' --output $@

# we remove online-B for gu-en as it has not been listed in the proceedings and later messes up correlation with HE.
download/wmt17-submitted-data/done : download/wmt17-submitted-data-v1.0.tgz
	$(DIR_GUARD)
	cd $(dir $<); tar -xzf $(notdir $<); 
	touch $@

data/wmt17/$(SRC)-$(TGT) : download/wmt17-submitted-data/done
	$(DIR_GUARD)
	cp -rf download/wmt17-submitted-data/txt/system-outputs/newstest2017/$(SRC)-$(TGT) $@

data/wmt17/$(SRC)-$(TGT)/newstest2017.HUMAN.$(SRC)-$(TGT) : download/wmt17-submitted-data/done data/wmt17/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf download/wmt17-submitted-data/txt/references/newstest2017-$(SRC)$(TGT)-ref.$(TGT) $@

### WMT18 ####################################################################################

download/wmt18-submitted-data-v1.0.1.tgz : 
	$(DIR_GUARD)
	curl 'http://data.statmt.org/wmt18/translation-task/wmt18-submitted-data-v1.0.1.tgz' --output $@

# we remove online-B for gu-en as it has not been listed in the proceedings and later messes up correlation with HE.
download/wmt18-submitted-data/done : download/wmt18-submitted-data-v1.0.1.tgz
	$(DIR_GUARD)
	cd $(dir $<); tar -xzf $(notdir $<); 
	touch $@

data/wmt18/$(SRC)-$(TGT) : download/wmt18-submitted-data/done
	$(DIR_GUARD)
	cp -rf download/wmt18-submitted-data/txt/system-outputs/newstest2018/$(SRC)-$(TGT) $@

data/wmt18/$(SRC)-$(TGT)/newstest2018.HUMAN.$(SRC)-$(TGT) : download/wmt18-submitted-data/done data/wmt18/$(SRC)-$(TGT)
	$(DIR_GUARD)
	cp -rf download/wmt18-submitted-data/txt/references/newstest2018-$(SRC)$(TGT)-ref.$(TGT) $@

#############################################################################################

results/newstest2015-$(SRC)$(TGT)-src.$(SRC).fw : download/wmt15-submitted-data/txt/sources/newstest2015-$(SRC)$(TGT)-src.$(SRC) splits/wmt15.$(SRC)$(TGT).split
	$(DIR_GUARD)
	paste $(word 2, $^) $(word 1, $^) | grep '^True' | cut -f 2 > $@

results/newstest2016-$(SRC)$(TGT)-src.$(SRC).fw : download/wmt16-submitted-data/txt/sources/newstest2016-$(SRC)$(TGT)-src.$(SRC) splits/wmt16.$(SRC)$(TGT).split
	$(DIR_GUARD)
	paste $(word 2, $^) $(word 1, $^) | grep '^True' | cut -f 2 > $@

results/newstest2017-$(SRC)$(TGT)-src.$(SRC).fw : download/wmt17-submitted-data/txt/sources/newstest2017-$(SRC)$(TGT)-src.$(SRC) splits/wmt17.$(SRC)$(TGT).split
	$(DIR_GUARD)
	paste $(word 2, $^) $(word 1, $^) | grep '^True' | cut -f 2 > $@

results/newstest2018-$(SRC)$(TGT)-src.$(SRC).fw : download/wmt18-submitted-data/txt/sources/newstest2018-$(SRC)$(TGT)-src.$(SRC) splits/wmt18.$(SRC)$(TGT).split
	$(DIR_GUARD)
	paste $(word 2, $^) $(word 1, $^) | grep '^True' | cut -f 2 > $@

results/wmt15.$(SRC)-$(TGT).%.fw.txt : splits/wmt15.$(SRC)$(TGT).split data/wmt15/$(SRC)-$(TGT) data/wmt15/$(SRC)-$(TGT)/newstest2015.HUMAN.$(SRC)-$(TGT) results/newstest2015-$(SRC)$(TGT)-src.$(SRC).fw
	$(DIR_GUARD)
	for output in data/wmt15/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt15.$(SRC)$(TGT).split <(cat $$output) | grep '^True' | cut -f 2 | \
		perl scripts/$*.pl $(TGT) counts/news.en.counts results/newstest2015-$(SRC)$(TGT)-src.$(SRC).fw; \
	done | perl -pe 's/data\/wmt15\/$(SRC)-$(TGT)\/newstest2015.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt16.$(SRC)-$(TGT).%.fw.txt : splits/wmt16.$(SRC)$(TGT).split data/wmt16/$(SRC)-$(TGT) data/wmt16/$(SRC)-$(TGT)/newstest2016.HUMAN.$(SRC)-$(TGT) results/newstest2016-$(SRC)$(TGT)-src.$(SRC).fw
	$(DIR_GUARD)
	for output in data/wmt16/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt16.$(SRC)$(TGT).split <(cat $$output) | grep '^True' | cut -f 2 | \
		perl scripts/$*.pl $(TGT) counts/news.en.counts results/newstest2016-$(SRC)$(TGT)-src.$(SRC).fw; \
	done | perl -pe 's/data\/wmt16\/$(SRC)-$(TGT)\/newstest2016.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt17.$(SRC)-$(TGT).%.fw.txt : splits/wmt17.$(SRC)$(TGT).split data/wmt17/$(SRC)-$(TGT) data/wmt17/$(SRC)-$(TGT)/newstest2017.HUMAN.$(SRC)-$(TGT) results/newstest2017-$(SRC)$(TGT)-src.$(SRC).fw
	$(DIR_GUARD)
	for output in data/wmt17/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt17.$(SRC)$(TGT).split <(cat $$output) | grep '^True' | cut -f 2 | \
		perl scripts/$*.pl $(TGT) counts/news.en.counts results/newstest2017-$(SRC)$(TGT)-src.$(SRC).fw; \
	done | perl -pe 's/data\/wmt17\/$(SRC)-$(TGT)\/newstest2017.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt18.$(SRC)-$(TGT).%.fw.txt : splits/wmt18.$(SRC)$(TGT).split data/wmt18/$(SRC)-$(TGT) data/wmt18/$(SRC)-$(TGT)/newstest2018.HUMAN.$(SRC)-$(TGT) results/newstest2018-$(SRC)$(TGT)-src.$(SRC).fw
	$(DIR_GUARD)
	for output in data/wmt18/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt18.$(SRC)$(TGT).split <(cat $$output) | grep '^True' | cut -f 2 | \
		perl scripts/$*.pl $(TGT) counts/news.en.counts results/newstest2018-$(SRC)$(TGT)-src.$(SRC).fw; \
	done | perl -pe 's/data\/wmt18\/$(SRC)-$(TGT)\/newstest2018.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

#############################################################################################
# in wrong direction, reference is native text, via grep -v

results/newstest2015-$(SRC)$(TGT)-src.$(SRC).bw : download/wmt15-submitted-data/txt/sources/newstest2015-$(SRC)$(TGT)-src.$(SRC) splits/wmt15.$(SRC)$(TGT).split
	$(DIR_GUARD)
	paste $(word 2, $^) $(word 1, $^) | grep -v '^True' | cut -f 2 > $@

results/newstest2016-$(SRC)$(TGT)-src.$(SRC).bw : download/wmt16-submitted-data/txt/sources/newstest2016-$(SRC)$(TGT)-src.$(SRC) splits/wmt16.$(SRC)$(TGT).split
	$(DIR_GUARD)
	paste $(word 2, $^) $(word 1, $^) | grep -v '^True' | cut -f 2 > $@

results/newstest2017-$(SRC)$(TGT)-src.$(SRC).bw : download/wmt17-submitted-data/txt/sources/newstest2017-$(SRC)$(TGT)-src.$(SRC) splits/wmt17.$(SRC)$(TGT).split
	$(DIR_GUARD)
	paste $(word 2, $^) $(word 1, $^) | grep -v '^True' | cut -f 2 > $@

results/newstest2018-$(SRC)$(TGT)-src.$(SRC).bw : download/wmt18-submitted-data/txt/sources/newstest2018-$(SRC)$(TGT)-src.$(SRC) splits/wmt18.$(SRC)$(TGT).split
	$(DIR_GUARD)
	paste $(word 2, $^) $(word 1, $^) | grep -v '^True' | cut -f 2 > $@

results/wmt15.$(SRC)-$(TGT).%.bw.txt : splits/wmt15.$(SRC)$(TGT).split data/wmt15/$(SRC)-$(TGT) data/wmt15/$(SRC)-$(TGT)/newstest2015.HUMAN.$(SRC)-$(TGT) results/newstest2015-$(SRC)$(TGT)-src.$(SRC).bw
	$(DIR_GUARD)
	for output in data/wmt15/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt15.$(SRC)$(TGT).split $$output | grep -v '^True' | cut -f 2 | \
		perl scripts/$*.pl $(TGT) counts/news.en.counts  results/newstest2015-$(SRC)$(TGT)-src.$(SRC).bw; \
	done | perl -pe 's/data\/wmt15\/$(SRC)-$(TGT)\/newstest2015.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt16.$(SRC)-$(TGT).%.bw.txt : splits/wmt16.$(SRC)$(TGT).split data/wmt16/$(SRC)-$(TGT) data/wmt16/$(SRC)-$(TGT)/newstest2016.HUMAN.$(SRC)-$(TGT) results/newstest2016-$(SRC)$(TGT)-src.$(SRC).bw
	$(DIR_GUARD)
	for output in data/wmt16/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt16.$(SRC)$(TGT).split $$output | grep -v '^True' | cut -f 2 | \
		perl scripts/$*.pl $(TGT) counts/news.en.counts results/newstest2016-$(SRC)$(TGT)-src.$(SRC).bw; \
	done | perl -pe 's/data\/wmt16\/$(SRC)-$(TGT)\/newstest2016.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt17.$(SRC)-$(TGT).%.bw.txt : splits/wmt17.$(SRC)$(TGT).split data/wmt17/$(SRC)-$(TGT) data/wmt17/$(SRC)-$(TGT)/newstest2017.HUMAN.$(SRC)-$(TGT) results/newstest2017-$(SRC)$(TGT)-src.$(SRC).bw
	$(DIR_GUARD)
	for output in data/wmt17/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt17.$(SRC)$(TGT).split $$output | grep -v '^True' | cut -f 2 | \
		perl scripts/$*.pl $(TGT) counts/news.en.counts results/newstest2017-$(SRC)$(TGT)-src.$(SRC).bw; \
	done | perl -pe 's/data\/wmt17\/$(SRC)-$(TGT)\/newstest2017.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@

results/wmt18.$(SRC)-$(TGT).%.bw.txt : splits/wmt18.$(SRC)$(TGT).split data/wmt18/$(SRC)-$(TGT) data/wmt18/$(SRC)-$(TGT)/newstest2018.HUMAN.$(SRC)-$(TGT) results/newstest2018-$(SRC)$(TGT)-src.$(SRC).bw
	$(DIR_GUARD)
	for output in data/wmt18/$(SRC)-$(TGT)/*; \
	do \
		echo -ne "$$output "; \
		paste splits/wmt18.$(SRC)$(TGT).split $$output | grep -v '^True' | cut -f 2 | \
		perl scripts/$*.pl $(TGT) counts/news.en.counts results/newstest2018-$(SRC)$(TGT)-src.$(SRC).bw; \
	done | perl -pe 's/data\/wmt18\/$(SRC)-$(TGT)\/newstest2018.(.+)\.[^\.]+ /$$1 /g' | sort -k2,2gr > $@


results/fig3.%.fw.png : \
  results/wmt15.$(SRC)-$(TGT).%.fw.txt \
  results/wmt16.$(SRC)-$(TGT).%.fw.txt \
  results/wmt17.$(SRC)-$(TGT).%.fw.txt \
  results/wmt18.$(SRC)-$(TGT).%.fw.txt \
  results/wmt19.$(SRC)-$(TGT).%.txt
	python3 scripts/boxplot.time.py $@ $^

results/fig3.%.bw.png : \
  results/wmt15.$(SRC)-$(TGT).%.bw.txt \
  results/wmt16.$(SRC)-$(TGT).%.bw.txt \
  results/wmt17.$(SRC)-$(TGT).%.bw.txt \
  results/wmt18.$(SRC)-$(TGT).%.bw.txt
	python3 scripts/boxplot.time.py $@ $^

#####################################################################################################

plots: \
    results/fig1.ttr.png results/fig1.mtld.png \
	results/fig2.ttr.png results/fig2.mtld.png \
	results/fig3.ttr.fw.png results/fig3.ttr.bw.png \
	results/fig3.mtld.fw.png results/fig3.mtld.bw.png