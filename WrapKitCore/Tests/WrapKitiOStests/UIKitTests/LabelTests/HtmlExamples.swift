//
//  HtmlExamples.swift
//  WrapKitTests
//
//  Created by Gulzat Zheenbek kyzy on 3/3/26.
//

import Foundation

enum HtmlTestCases {
    // 1) <p>, <br>, <strong>
    static let example1 = """
                    <p>1. Проведите пальцем сверху вниз — откроется шторка уведомлений.<br>
                    2. Найдите нужное уведомление от Мой О!<br></p>
                    <p><strong>Если уведомления нет?</strong><br>
                    Настройки телефона &gt; Уведомления &gt; найдите приложение Мой О! и включите уведомления.</p>
    """
    
    // 2) Проверка bold/italic одновременно
    static let boldItalic = """
    <p>Обычный текст, <strong>жирный</strong>, <em>курсив</em>, <strong><em>жирный+курсив</em></strong>.</p>
    """
    
    // 3) Inline style: font-size / font-weight (700/400) внутри span Inline color
    static let inlineStyle = """
    <p>
      <span style="font-size:22px; font-weight:700;">Hello</span> world
      <span style="font-size:12px; font-weight:400;">small text</span>
    </p>
    
    <p>
      <span style="color:#FF0000;">Red</span>,
      <span style="color:rgb(0,128,0);">Green</span>,
      <span style="color:blue;">Blue</span>
    </p>
    """

    static let inlineSizeWeight = """
    <p>
      <span style="font-size:22px; font-weight:700;">Hello</span> world
      <span style="font-size:12px; font-weight:400;">small text</span>
    </p>
    """

    static let inlineColors = """
    <p>
      <span style="color:#FF0000;">Red</span>,
      <span style="color:rgb(0,128,0);">Green</span>,
      <span style="color:blue;">Blue</span>
    </p>
    """
    
    // 5) Несколько абзацев: проверка paragraphSpacing / paragraphSpacingBefore
    static let paragraphs = """
    <p>Первый абзац. Должен быть отдельным параграфом.</p>
    <p>Второй абзац. Между ними должен работать paragraphSpacing.</p>
    <p><strong>Третий абзац</strong> с жирным заголовком.</p>
    """
    
    // 6) Списки: <ul>/<ol> (важно не ломать paragraphStyle из HTML)
    static let lists = """
    <p><strong>Плюсы:</strong></p>
    <ul>
      <li>Быстро</li>
      <li>Понятно</li>
      <li><strong>Важно</strong> для пользователя</li>
    </ul>
    <p><strong>Шаги:</strong></p>
    <ol>
      <li>Откройте настройки</li>
      <li>Найдите Мой О!</li>
      <li>Включите уведомления</li>
    </ol>
    """
    
    static let links = """
    <p>
      Перейдите на <a href="https://example.com">сайт поддержки</a> и прочитайте инструкцию.
    </p>
    """
    
    // 8) Проверка line-height / letter-spacing (HTML может их парсить частично)
    // Проверка text-align (HTML) и textAlignment (config) поверх
    //  Ссылки: <a> + проверка, что текст не разваливается
    // Проверка подчеркивания
    // Смешанные стили + вложенность
    static let other = """
    <p>
      Перейдите на <a href="https://example.com">сайт поддержки</a> и прочитайте инструкцию.
    </p>
    <p>
      <span style="line-height:150%; letter-spacing:1px;">
        Текст с увеличенной высотой строки и межбуквенным интервалом.
      </span>
    </p>
    <p style="text-align:center;">Центр</p>
    <p style="text-align:right;">Право</p>
    <p style="text-align:left;">Лево</p>
    <p>Обычный <u>подчеркнутый</u> текст и <strong><u>жирный+подчеркнутый</u></strong>.</p>
    <p>
      <span style="font-size:18px;">
        Большой текст, <strong>жирный</strong>,
        <em>курсив</em>, и <strong><em>оба</em></strong>.
      </span>
    </p>
    """
    
    // 10) Проверка переносов и длинного текста (lineBreakMode)
    static let longText = """
    <p>
      ОченьдлинноесловобезпробеловОченьдлинноесловобезпробеловОченьдлинноесловобезпробелов
      и дальше обычный текст чтобы проверить переносы.
    </p>
    """
    // 12)
    static let exampleStyle = """
    <h4 style="font-size: 17px; font-weight: 600; margin-bottom: 8px;">Как это работает?</h4>
    <p> • Пополнить баланс перед списанием оплаты за тариф и услуги.</p>
    <p> • Подобран на основе суммы, которую вы регулярно оплачиваете за тариф и услуги.</p>
    <p> • Оплата пройдет без подтверждения со счёта по умолчанию в O!Bank.</p>
    <h4 style="font-size: 17px; font-weight: 600; margin-bottom: 8px; margin-top: 32px;">Почему это удобно и выгодно?</h4>
    <p> • Вы всегда на связи без напоминаний и лишних действий.</p>
    <p> • Оплачивая услуги О! вы получаете кешбэк 1%.</p>
    """
}
