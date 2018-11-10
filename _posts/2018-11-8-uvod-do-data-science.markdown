---
layout: post
title:  "Jemný úvod do datové vědy"
date:   2018-11-08 17:38:03 +0200
excerpt_separator: <!--more-->
---
V tomto článku bych rád představil základní metody *web-scrapingu* a následného zpracování získaných dat pomocí nástroje `jupyter notebook`. Článek je určený pro programováním lehce políbené jedince a je prakticky zaměřený.

<!--more-->

Je potřeba sehnat potřebné nástroje. Velmi doporučuji celý balík [`Anaconda`](https://www.anaconda.com/), který je pro podobné účely určen. Instalace by měla proběhnout bez problémů. Kdyžtak se ptejte [zde](google.com) nebo mi napište a třeba vám pomůžu. Asi nemá smysl popisovat ovládání Jupyteru, k tomu slouží podrobná [dokumentace](https://jupyter-notebook.readthedocs.io/en/stable/notebook.html).

## Úkol
Řekněme, že chceme zobrazit informace o obcích v okrese Rokycany. Stáhnout někde připravená data je příliš jednoduchý úkol a nebyly by vysvětleny základy *web-scrapingu*. Každý takový úkol začíná hledáním informací. Obvykle může jít o nějakou veřejnou databázi, články apod. V našem případě to bude *Wikipedie*, což úkol možná trošku zlehčuje, protože její stránky jsou výborně strukturované. 

Nejdříve tedy stáhneme potřebná data.


Do *listu* uložíme semínko, ze kterého prorosteme do kýžených ostatních stránek. Zvolil jsem náhodně Dobřív. Pokud se podíváte na strukturu stránky, vidíte dole v boxu ostatní obce. 

![Screenshot](/assets/dobrivwiki.png)

Pomocí vývojářských nástrojů v prohlížeči (`F12`) najedeme na box. Vlevo se promítne struktura. Je vidět, že seznam obcí je pod elementem `td` specifikovaným pomocí `class="navbox-list"`. V `Jupyteru` se průběžně můžete koukat, jak stažená data vypadají a podle toho *těžit*. V zásadě obvykle stačí relativně malá sada příkazů, více se dočtete v dokumantaci k balíčku `bs4`.

``` python
from bs4 import BeautifulSoup
import requests

urls = ['/wiki/Dob%C5%99%C3%ADv']
dobriv = requests.get("https://cs.wikipedia.org" + urls[0])
soup = BeautifulSoup(dobriv.text, 'html.parser')

for link in soup.find_all("td", {"class": "navbox-list"})[1].div.find_all("a"):
    try:
        urls.append(link["href"])
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
Což stáhne všechna data. Ale ty se nacházejí v poněkud znečištěné formě, stejně jako s názvy sloupců není vše v pořádku, obsahují mezery a jiné ošklivé znaky. Dodejme datům nástroje. To nejlépe splní balíček `pandas`

``` python
import pandas as pd

df = pd.DataFrame(table)
df = df.replace('\n','', regex=True)
df.columns = df.columns.str.strip().str.lower().str.replace(' ', '_').str.replace('.', '')
df.to_csv('obce.csv', sep='\t', encoding='utf-8') #backup
```

Další úpravy sloupců jsou však nutné. Například přetypování čísel a tak dále. Více v mém *repu* na Githubu.

![Korelace](/assets/corr.png 'Korelace'){: .center}
