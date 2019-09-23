
# AI in Azure: Workshop
___Интесив по технологиям машинного обучения в облаке Microsoft Azure___


_Цель курса_: дать представление о дисциплинах Машинное обучение (_Machine Learning_) и Глубокое обучение (_Deep Learning_), 
а также познакомить слушателей с сервисами машинного обучения в облаке Microsoft Azure. 

[Вводный ролик к курсу](https://youtu.be/aew5exB5Xxg)


## Программа курса
### Введение в машинное обучение

Темы занятия:
* Основная терминология, область применения и актуальность
* _Типовые ML задачи:_ обучение с учителем, обучение без учителя, обучение с подкреплением
* _Классы алгоритмов:_ регрессия, классификация, кластеризация
* _Интуитивное понимание алгоритмов:_ от линейной регрессии до нейронных сетей.

Материалы лекции:
* [Презентация](https://1drv.ms/p/s!Aq3CCEvm580vjLkCLr7vKvADYpWZgA?e=mKuzCn).

Дополнительные материалы по теме:
* [Курс Машинное обучение](https://ru.coursera.org/learn/machine-learning), Stanford University
* [Курс Введение в машинное обучение](https://ru.coursera.org/learn/vvedenie-mashinnoe-obuchenie), ВЭШ и ШАД Яндекс.


### Azure AI Platform

Темы занятия:
* Data Science инструменты в Azure: основные языки программирования, ML-фреймворки и облачные сервисы.
* Выбираем ML-сервис для конкретной задачи

Материалы лекции:
* [Презентация](https://1drv.ms/p/s!Aq3CCEvm580vjLkDGRcDRPR4GwXG-A?e=6jjCJw)
* Видеоурок [Введение в Azure AI Platform](https://youtu.be/G-37PWkftGg).

Дополнительные материалы по теме:
* [Azure.com/AI](https://www.azure.com/ai)
* [Microsoft AI Blog](https://blogs.microsoft.com/ai/)
* [Microsoft Azure for Research Program](https://www.microsoft.com/en-us/research/academic-program/microsoft-azure-for-research/).


### Azure Machine Learning Studio

Темы занятия:
* Обзор сервиса _Azure ML Studio_
* Получение и трансформация данных в _Azure ML Web Studio_
* ML-алгоритмы, обучение и оценка моделей в Azure ML Web Studio
* _Azure Notebooks_: интерактивное приложение для анализа и разработки ML-моделей.

Практическая работа:
* Cоздание [Azure Machine Learning workspace](https://studio.azureml.net/)
* Первые шаги в Azure ML Studio:
  * Задача классификации диабета в Azure ML Web Studio
  * Задача классификации онкологических заболеваний в Azure Notebooks
* Продвинутые техники работы с Azure ML Studio:
  * [Семантический анализ твитов в Azure ML Web Studio](https://www.codeinstinct.pro/2015/12/community-dev-camp14.html)
  * Создание REST сервиса анализа твитов в Azure ML Web Services.

Материалы лекции:
* [Презентация](https://1drv.ms/p/s!Aq3CCEvm580vjLkDGRcDRPR4GwXG-A?e=6jjCJw)
* Видеоурок [Начало работы в Azure ML Studio](https://youtu.be/TXBV2Nnrpfc).

Дополнительные материалы по теме:
* [Azure Machine Learning documentation](https://docs.microsoft.com/en-us/azure/machine-learning/)
* [Machine Learning Algorithm Cheat Sheet](https://docs.microsoft.com/en-us/azure/machine-learning/studio/algorithm-cheat-sheet)
* [Лекция в ВШЭ/МАМИ по Azure Machine Learning](https://www.codeinstinct.pro/2015/10/azureml-lecture-at-hse.html)
* [Хакатон по машинному обучению: Прийти. Обучить модель. Победить!](https://www.codeinstinct.pro/2015/11/azure-ml-hackathon.html)
* [Machine Learning Studio pricing](https://azure.microsoft.com/pricing/details/machine-learning-studio/).


### Введение глубокие нейронные сети
Темы занятия:
* Современный этап развития нейронных сетей
* _Типы нейронных сетей:_
  * Полносвязанные сети прямого распространения (FNN)
  * Сверочные нейронные сети (CNN) 
  * Рекуррентные нейронные сети (RNN)
  * Состязательные нейронные сети (GAN).

Материалы лекции:
* [Презентация](https://1drv.ms/p/s!Aq3CCEvm580vjLkEnIm-_G37lRIkZg?e=Jtcp8T).

Дополнительные материалы по теме:
* [Курсы по специализации Deep Learning](https://www.deeplearning.ai/deep-learning-specialization/), Andrew Ng, et al.
* [Deep Learning Book](http://www.deeplearningbook.org/), Ian Goodfellow, et al.


### Azure Data Science VM

Темы занятия:
* _Виртуальные машины для обучения ML-моделей_: IaaS для ML и типы образов VM для Data Science
* _Automated ML_: обзор, популярные фреймворки, Auto ML в Azure.

Практическая работа:
* Развертывание Azure Deep Learning VM
* Практикум по компьютерному зрению:
  * Распознание рукописного написания цифр (база MNIST): [Azure ML](https://gallery.azure.ai/Experiment/Neural-Network-Convolution-and-pooling-deep-net-2), [keras](demos/mnist-cnn-model--keras/).

Материалы лекции:
* [Презентация](https://1drv.ms/p/s!Aq3CCEvm580vjLkDGRcDRPR4GwXG-A?e=6jjCJw)
* [Презентация по Auto ML](http://0xcode.in/auto-ml-intro)
* Видеоурок [Нейронные сети в Azure ML Studio](https://youtu.be/Pa5DmvvcwLI).

Дополнительные материалы по теме:
* [Azure Data Science VM documentation](https://docs.microsoft.com/en-us/azure/machine-learning/data-science-virtual-machine/)
* [Azure Automated ML documentation](https://docs.microsoft.com/en-us/azure/machine-learning/service/concept-automated-ml).


### Другие инструменты для Data Science в Azure

Темы занятия:
* DevOps для Data Science
* Наборы данных:
  * [Azure Open Datasets](https://azure.microsoft.com/en-in/services/open-datasets/)
  * [Kaggle Datasets](https://www.kaggle.com/datasets)
  * [github.com/awesomedata](https://github.com/awesomedata/awesome-public-datasets)
* Поиск решений community:
  * AI list on [arxiv.org](https://arxiv.org/list/cs.AI/recent)
  * [datascience.stackexchange.com](https://datascience.stackexchange.com/)
  * [github.com](https://github.com/)
* DS-cоревнования
  * [Kaggle](https://www.kaggle.com/)
  * [Тренировки и разбор соревнований](https://mltrainings.ru/).

Материалы лекции:
* [Презентация](https://www.codeinstinct.pro/2018/11/data-science-in-cloud.html).


### Финальный проект

Участвуем в соревновании Kaggle:
* [Регистрация на Kaggle](https://www.kaggle.com/)
* Выбор kernel'a и запуск обучения модели в облаке Azure.


## Требование к слушателям
### Обязательные требования
1. Современный веб-браузер;
2. [Microsoft Account](https://account.microsoft.com/).

### Рекомендованные требования
1. Знание Python или R
2. [Учетная запись в Azure](https://azure.microsoft.com/en-us/).
