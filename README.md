# SF-3 sf__wordpress_staging

Задеплоить Wordpress на продуктивную ВМ

## Подготовка ВМ

Для тестирвоания продуктивного развертывания виртуалка может быть оперативно развернута в Yandex.Cloud:

    yc vpc network create \
        --name sf__wp_stage \
        --labels env=SKF \
        --description "SF-3 sf__wordpress_staging"

    yc vpc subnet create \
        --name sf-172.23.0 \
        --zone ru-central1-b \
        --range 172.23.0.0/24 \
        --network-name sf__wp_stage \
        --description "SF-3 net"

    yc compute instance create \
        --name sfwpstage \
        --network-interface subnet-name=sf-172.23.0,nat-ip-version=ipv4 \
        --zone ru-central1-b \
        --create-boot-disk image-id="fd8vmcue7aajpmeo39kk",size=16,auto-delete \
        --cores 2 --core-fraction 5 --memory 1 \
        --ssh-key ~/.ssh/id_rsa.pub

Для получения публичного IP адреса разворачиваемой виртуалки можно передать вывод последней команды на

    | yq -y .network_interfaces[0].primary_v4_address.one_to_one_nat.address

либо посмотреть его в консоли Yandex.Cloud (ибо `yq` обычно по умолчанию отсутствует)

## Настройка Ubuntu и установка Wordpress

Поскольку продуктивная виртуалка должна быть развернута заранее (другими службами, возможно на ней запущены и другие сервисы...), вышеприведенные команды не входят в единый скрипт.  

Для развертывания продуктива ранее отлаженные команды из Vagrantfile удобно преобразовать в ansible.  
Для запуска я обычно пользуюсь скриптом, позволяющим сфокусироваться только на значимых параметрах (имя пользователя, IP адрес, имя хоста и т.п.), поскольку речи о регулярном запуске на многих хостах не идет, и использование inventory нецелесообразно.  

`./aplay.sh -k id_rsa -u yc-user -i 130.193.40.177 -h sfwpstage -p wordpress.yml | tee ansible.log`

Результат:

    PLAY RECAP ******************************************************************************************
    130.193.40.177: ok=26   changed=23   unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

Для подключения по доменному имени я использую возможность DDNS, предоставляемую сервисом namecheap, где у меня зарегистрирован домен для тестов.  
В продуктиве, разумеется, IP адрес будет статическим. В таком случае секцию `# ddnsclient` в `wordpress.yml` следует исключить.

Настройка параметров развертывания Wordpress (база данных, учетные записи и т.п. производится в `config.yaml`)

## Подключение

http://sfwpstage.arlab.pw

Имя хоста: параметр `siteurl` в `config.yaml`  
Там же указаны имя/пароль пользователя с правами администратора, для подключения к /wp-admin
