---
layout: post
title:  "Jemný úvod do datové vědy: web-scrapping"
date:   2018-11-10 17:38:03 +0200
excerpt_separator: <!--more-->
tags: ["data_science", "python", "jupyter", "uvod"]
---
V prvním článku série bych rád představil základní metody *web-scrapingu* a následného zpracování získaných dat pomocí nástroje `jupyter notebook`, `Beaufitul Soup` a `pandas`. Článek je určený pro programováním lehce políbené jedince a je prakticky zaměřený.

<!--more-->

Je potřeba sehnat potřebné nástroje. Velmi doporučuji celý balík [`Anaconda`](https://www.anaconda.com/), který je pro podobné účely určen. Instalace by měla proběhnout bez problémů. Kdyžtak se ptejte na Google nebo mi napište a třeba vám pomůžu. Asi nemá smysl popisovat ovládání Jupyteru, k tomu slouží podrobná [dokumentace](https://jupyter-notebook.readthedocs.io/en/stable/notebook.html). V zásadě se jedná o sešit, který usnadňuje manipulaci s výstupními daty, které `python` poskytne (obrázky, tabulky, etc.).

### Úkol
Řekněme, že chceme shromáždit a vizualisovat základní informace o obcích v okrese Rokycany. Stáhnout někde připravená data je příliš jednoduchý úkol a nebyly by vysvětleny základy *web-scrapingu*. Každý takový úkol začíná hledáním informací. Obvykle může jít o nějakou veřejnou databázi, články apod. V našem případě to bude *Wikipedie*, což úkol možná *velmi mírně* zlehčuje, protože její stránky jsou výborně strukturované. 

### Vytěžení dat

Nejdříve tedy stáhneme potřebná data.

Dobrá strategie je najít nějaký rozcestník, odkud vysajeme adresy jednotlivých obcí. Zvolme náhodně třeba Dobřív. Wikipedie obvykle poskytuje rozcestníky na podobná témata nebo na témata stejné kategorie. Pokud budete využívat jiný webový informační zdroj než Wikipedii, situace bude nejspíše podobná. V krajním případě je možné prolézt výsledky *nějakého* vyhledávače.

![Screenshot](/assets/dobrivwiki.png)

Pomocí vývojářských nástrojů v prohlížeči (`F12`) najedeme na box obcí. Vpravo (nebo dole) se promítne struktura HTML. Je vidět, že seznam obcí je pod elementem `td` specifikovaným pomocí `class="navbox-list"`. V `Jupyteru` se průběžně můžete koukat, jak stažená data vypadají a podle toho *těžit*. V zásadě obvykle stačí relativně malá sada příkazů, více se dočtete v dokumantaci k balíčku `bs4`. Následující kód shromáždí všechna url do *listu* `urls`.

``` python
from bs4 import BeautifulSoup # balík umožňující manipulaci s HTML
import requests # balík umožňující stáhnout stránku (mimo jiné)

urls = ['/wiki/Dob%C5%99%C3%ADv'] # zkopírováno z URL panelu v prohlížeči
dobriv = requests.get("https://cs.wikipedia.org" + urls[0])
soup = BeautifulSoup(dobriv.text, 'html.parser') # parsing HTML pomocí bs4 umožňující další manipulaci

for link in soup.find_all("td", {"class": "navbox-list"})[1].div.find_all("a"):
    try:
        urls.append(link["href"]) # uloží url, try blok igoruje chyby, např. neexistenci href parametru
    except:
        continue
```

Máme tedy všechny adresy. Nyní *scrapneme* kýžené informace. V zásadě projedeme *list* `urls` a pro každý prvek vytvoříme *request*, z něj vesele uložíme požadované informace a pokračujeme dál až do konce. Následující kód tedy nejspíše nikoho nepřekvapí. 

``` python
import unidecode #remove czech akcent characters
table = []
for link in urls:
    page = requests.get("https://cs.wikipedia.org" + link)
    parse = BeautifulSoup(page.text, 'html.parser')
    town_head = parse.find_all("table", {"class": "infobox"})[0].find_all("tr")
    town = {}
    town['Jmeno'] = parse.find("h1").text
    for i in town_head:
        try:
            town[unidecode.unidecode(i.find("th").text)] = i.find("td").text
        except:
            continue
    table.append(town)
```
Což stáhne všechna data. Ale ty se nacházejí v poněkud znečištěné formě, stejně jako s názvy sloupců není vše v pořádku, obsahují mezery a jiné ošklivé znaky. Dodejme k datům nástroje. To nejlépe splní balíček `pandas`. Doporučuji pročíst dokumentaci.

``` python
import pandas as pd

df = pd.DataFrame(table) #uloží naše data do DataFrame tabulky
df = df.replace('\n','', regex=True)
df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_').str.replace('.', '')
df.to_csv('obce.csv', sep='\t', encoding='utf-8') #backup
```

Další úpravy sloupců jsou však nutné. Například přetypování čísel a tak dále. Je to již poměrně repetetivní práce a proto vás odkáži na svůj github, kde je kompletní [jupyterovský notebook](https://github.com/badgercz/ds_intro/blob/master/notebook.ipynb) k nahlédnutí.

Pomocí metod `head`, `info` a `describe` nad tabulkou si uděláme obrázek o kvalitě a kvantitě získaných dat.

![Screenshot](/assets/head.png)

![Screenshot](/assets/info.png)

![Screenshot](/assets/describe.png)


