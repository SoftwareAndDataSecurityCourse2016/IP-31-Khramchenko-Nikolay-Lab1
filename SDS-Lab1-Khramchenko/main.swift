//
//  main.swift
//  SDS-Lab1-Khramchenko
//
//  Created by Nikolay Khramchenko on 9/22/16.
//  Copyright © 2016 KPI. All rights reserved.
//

import Foundation;

extension Array {
    //Перемешивания элементов массива в случайном порядке
    mutating func shuffle() {
        for i in 0 ..< self.count {
            let random = Int(arc4random()) % self.count;
            let t = self[i];
            self[i] = self[random];
            self[random] = t;
        }
    }
    
}

extension String {
    //Длинна строки - Int
    var length: Int { return characters.count; }
    
    //Обрезает строку 
    //
    //Параметры:
    //startIndex (Int) - номер символа с которого обрезать строку
    //length (Int) - длинна обрезаной строки
    //
    //Возвращает обрезанную строку
    func subString(startIndex: Int, length: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: startIndex);
        let end = self.index(self.startIndex, offsetBy: (startIndex + length));
        return self[start ..< end];
    }
}

class NGrammMap {
    private static var instance : NGrammMap? = nil;
    
    var size : Int = 0; //Количество символов в n-грамме
    var map : [String : Double] = [:]; //мапа [n-грамм : частота испольования в тексте]
    var min = Double(0); //значение для n-грамма, если его нет в мапе
    
    static func getInstance(size : Int) -> NGrammMap {
        if (NGrammMap.instance == nil) {
            NGrammMap.instance = NGrammMap(size: size);
        } else if (NGrammMap.instance?.size != size) {
            NGrammMap.instance = NGrammMap(size: size);
        }
        
        return NGrammMap.instance!;
    }
    
    private init(size : Int) {
        self.size = size;
        do {
            let fileRoot = Bundle.main.path(forResource: "\(size)", ofType: "txt");
            let stringFromFile = try String(contentsOfFile: fileRoot!);
            let ngramms = stringFromFile.components(separatedBy: "\n");
            
            var total = Double(0);
        
            for ngramm in ngramms {
                let t = ngramm.components(separatedBy: " ");
                if (t.count > 1) {
                    let value = Double(t[1]);
                    self.map[t[0]] = value;
                    total += value!;
                }
            }
            
            self.min = log10(0.01 / total);
            
            for (key, value) in self.map {
                self.map[key] = log10(value / total);
            }
            
        } catch {
            print("error");
        }
    }
}


//Подсчет критерия, который показывает на сколько текст соответствует реальному английскому тексту
//
//Параметры:
//text (String) - текст, для которого будет высчитан критерий соответствия
//size (Int) - количество символов в n-грамме в диапазоне [1..5]
//По умолчанию size = 3;
//
//Возвращает -1, если size < 1 или size > 5 иначе
//число типа Double - критерий соответствия текста к реальному английскому тексту
//
//Таблица частотности использования n-граммов была взята с сайта: http://
func calculateCriterion(text : String, size : Int = 3) -> Double {
    if (size < 1 || size > 5) {
        return -1;
    }
    
    var quantity = Double(0);
    
    for i in 0 ..< (text.length - size + 1) {
        let tngramm = text.subString(startIndex: i, length: size);
        if (NGrammMap.getInstance(size: size).map[tngramm] != nil) {
            quantity += NGrammMap.getInstance(size: size).map[tngramm]!;
        } else {
            quantity += NGrammMap.getInstance(size: size).min;
        }
    }
    
    return quantity;
}

//Подстановка букв в текст согласно ключа
//
//Параметры:
//text (String) - зашифрованый текст
//key ([String]) - ключ
//
//Возвращает текст (String) расшифрований ключем
func decrypt(text : String, key : [String]) -> String {
    let alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
    var text = text;
    for i in 0 ..< alphabet.count {
        text = text.replacingOccurrences(of: alphabet[i], with: key[i].lowercased());
    }
    return text.uppercased();
}

let text = "EFFPQLMEHEMVPCPYFLMVHQLUHYTCETHQEKLPVMMVHQLUWEOLFPQLIVDLWLULMVHQLUCYAUHUYDUEOSQYATFFVSMUVOVWEPLPQVSPCHLYGETDYUVPQOGUYOOYWYETHQEKLPVMYWLSASVWDEWCPLSPYGDYYFWLSSYGGVPCYAEULMYOGYUPEKTLBVPQCYAOECASLVWFLRYGMYVWMVFLWMLNESVSNVLREOVWEPVYWSPEPVSPVMETPLSPSYUBQEPLILUOLPQYFCYAGLLTBVTTSQYBPQLKLSPULSATPPUCPYPQVWNYGBQEPBVTTQEHHLWVGPQLNLCMYWPEVWSSEOLMQEUEMPLUSEPFVGGLULWPHYSVPVYWSBVTTCYAUHUYDUEOSPVTTKLQEILMYUULMPTC";

var key = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];

var criterion = Double(Int.min);

for i in 0 ..< 3 {
    var rKey = key;
    rKey.shuffle();
    var rC = calculateCriterion(text: decrypt(text: text, key: rKey), size : 3);
    
    var j = 0;
    while (j < 1000) {
        let r1 = Int(arc4random() % 26);
        let r2 = Int(arc4random() % 26);
        
        var k = rKey;
        
        let t = k[r1];
        k[r1] = k[r2];
        k[r2] = t;
        
        let c = calculateCriterion(text: decrypt(text: text, key: k), size : 3);
        
        if (c > rC) {
            rC = c;
            rKey = k;
            j = 0;
        }
        
        j += 1;
        
    }
    
    if (rC > criterion) {
        criterion = rC;
        key = rKey;
    }

}
print(key);
print(decrypt(text: text, key: key));
