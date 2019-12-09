//
//  ContentView.swift
//  Mulder
//
//  Created by Erik Pragt on 8/12/19.
//  Copyright © 2019 Erik Pragt. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {        
        Image("background" + String(Int.random(in: 0 ..< 3)))
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
