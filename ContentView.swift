//
//  ContentView.swift
//  SantosLaguna
//
//  App informativa del Club Santos Laguna (Torreón, Coahuila).
//  NO tiene botones: todo se maneja con gestos.
//   - Deslizar a la izquierda / derecha: cambia de pantalla
//   - Tap, doble tap y presión larga en el balón de la portada
//   - Pellizcar (magnify) los íconos de cada tema
//   - Arrastrar, pellizcar y rotar el balón en la cancha
//

import SwiftUI
import MapKit

// Colores del equipo
extension Color {
    static let verdeSantos = Color(red: 0.0, green: 0.52, blue: 0.29)
    static let verdeOscuro = Color(red: 0.0, green: 0.33, blue: 0.18)
}

// Foto del proyecto (Assets.xcassets). Si todavía no agregas la imagen,
// muestra un recuadro verde con el ícono para que la app no se vea vacía.
// Gesto: pellizca la foto para hacer zoom.
struct FotoSantos: View {
    let nombre: String
    let simbolo: String
    var alto: CGFloat = 220

    @State private var zoom: CGFloat = 1.0

    var body: some View {
        Group{
            if UIImage(named: nombre) != nil {
                Image(nombre)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack{
                    LinearGradient(colors: [.verdeSantos, .verdeOscuro],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    VStack(spacing: 8){
                        Image(systemName: simbolo).font(.system(size: 50))
                        Text("Agrega la imagen \"\(nombre)\"").font(.caption)
                    }
                    .foregroundStyle(.white)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: alto)
        .scaleEffect(zoom)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 4)
        .gesture(
            MagnifyGesture()
                .onChanged { valor in
                    zoom = min(max(valor.magnification, 1.0), 3.0)
                }
                .onEnded { _ in
                    withAnimation(.spring) { zoom = 1.0 }
                }
        )
    }
}

// Nombres de las pantallas (para el indicador de abajo)
let nombresPaginas = ["Inicio", "Historia", "Títulos", "Estadio", "Ídolos", "Cancha"]

// Navegación SOLO con gestos: desliza a la izquierda o derecha para cambiar de pantalla.
struct ContentView: View {
    // 0 = Inicio, 1 = Historia, 2 = Títulos, 3 = Estadio, 4 = Ídolos, 5 = Cancha
    @State private var paginaActual = 0

    var body: some View {
        ZStack(alignment: .bottom){
            // El TabView con estilo de página cambia de pantalla al deslizar el dedo
            TabView(selection: $paginaActual){
                NavigationStack{ PortadaView() }.tag(0)
                NavigationStack{ HistoriaView() }.tag(1)
                NavigationStack{ TitulosView() }.tag(2)
                NavigationStack{ EstadioView() }.tag(3)
                NavigationStack{ IdolosView() }.tag(4)
                NavigationStack{ CanchaView() }.tag(5)
            }
            // Ocultamos los puntitos del sistema porque se pueden tocar como botón
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)

            // Indicador propio (solo informativo, no se puede tocar)
            IndicadorDeslizar(paginaActual: paginaActual)
                .allowsHitTesting(false)
                .padding(.bottom, 8)
        }
        .tint(.verdeSantos)
    }
}

// Indicador inferior: muestra en qué pantalla estás y hacia dónde puedes deslizar
struct IndicadorDeslizar: View {
    let paginaActual: Int

    var body: some View {
        VStack(spacing: 6){
            HStack{
                if paginaActual > 0 {
                    Label(nombresPaginas[paginaActual - 1], systemImage: "chevron.left")
                } else {
                    Text(" ")
                }
                Spacer()
                if paginaActual < nombresPaginas.count - 1 {
                    HStack(spacing: 4){
                        Text(nombresPaginas[paginaActual + 1])
                        Image(systemName: "chevron.right")
                    }
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            HStack(spacing: 8){
                ForEach(0..<nombresPaginas.count, id: \.self){ i in
                    Capsule()
                        .fill(i == paginaActual ? Color.verdeSantos : Color.gray.opacity(0.35))
                        .frame(width: i == paginaActual ? 22 : 8, height: 8)
                }
            }
            .animation(.spring, value: paginaActual)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial, in: Capsule())
        .padding(.horizontal)
    }
}

// Portada (sin botones)
struct PortadaView: View {
    // Estados para los gestos de la portada
    @State private var escalaBalon: CGFloat = 1.0
    @State private var giroBalon: Double = 0
    @State private var mensajeGesto = "Toca, mantén presionado o toca dos veces el balón"
    @State private var esGuerrero = false
    @State private var moverFlecha = false

    var body: some View {
        ScrollView{
            VStack (spacing: 20){
                Text("Santos Laguna").font(.largeTitle).bold().multilineTextAlignment(.center)
                Text("Los Guerreros de la Comarca Lagunera").foregroundStyle(.secondary)

                FotoSantos(nombre: "portada", simbolo: "photo")

                // Franjas verdiblancas y balón con gestos
                ZStack{
                    HStack(spacing: 0){
                        ForEach(0..<8){ i in
                            Rectangle().fill(i % 2 == 0 ? Color.verdeSantos : Color.white)
                        }
                    }
                    Image(systemName: esGuerrero ? "trophy.fill" : "soccerball")
                        .font(.system(size: 90))
                        .foregroundStyle(esGuerrero ? Color.yellow : Color.black)
                        .padding(20)
                        .background(Circle().fill(.white).shadow(radius: 6))
                        .scaleEffect(escalaBalon)
                        .rotationEffect(.degrees(giroBalon))
                        // Doble tap: cambia el balón por el trofeo
                        .onTapGesture(count: 2){
                            withAnimation(.spring) { esGuerrero.toggle() }
                            mensajeGesto = esGuerrero ? "¡Campeones! 🏆" : "De vuelta a la cancha ⚽"
                        }
                        // Tap: el balón brinca y gira
                        .onTapGesture{
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                                escalaBalon = 1.3
                                giroBalon += 360
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
                                withAnimation(.spring) { escalaBalon = 1.0 }
                            }
                            mensajeGesto = "¡Golazo! ⚽"
                        }
                        // Presión larga: grito de la afición
                        .onLongPressGesture(minimumDuration: 0.6){
                            mensajeGesto = "¡Vamos Santos, vamos Guerreros! 💚🤍"
                        }
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(mensajeGesto)
                    .font(.subheadline)
                    .foregroundStyle(Color.verdeOscuro)
                    .multilineTextAlignment(.center)

                // Lista de temas (solo informativa, se llega deslizando)
                VStack(alignment: .leading, spacing: 12){
                    Text("Lo que vas a encontrar").font(.headline)
                    FilaTema(numero: 1, titulo: "Historia", simbolo: "book.closed", color: .verdeSantos)
                    FilaTema(numero: 2, titulo: "Títulos", simbolo: "trophy", color: .orange)
                    FilaTema(numero: 3, titulo: "Estadio", simbolo: "map", color: .blue)
                    FilaTema(numero: 4, titulo: "Ídolos", simbolo: "star.fill", color: .purple)
                    FilaTema(numero: 5, titulo: "Juega con el balón", simbolo: "soccerball", color: .verdeOscuro)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Pista animada para deslizar
                HStack(spacing: 10){
                    Image(systemName: "hand.point.up.left.fill")
                        .offset(x: moverFlecha ? -20 : 10)
                    Text("Desliza a la izquierda para comenzar")
                }
                .font(.headline)
                .foregroundStyle(Color.verdeSantos)
                .onAppear{
                    withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)){
                        moverFlecha = true
                    }
                }
            }
            .padding()
            .padding(.bottom, 80)
        }
        .background(Color.verdeSantos.opacity(0.06))
        .navigationTitle("Club Santos Laguna")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Fila informativa de un tema (no es botón)
struct FilaTema: View {
    let numero: Int
    let titulo: String
    let simbolo: String
    let color: Color

    var body: some View {
        HStack(spacing: 12){
            Image(systemName: simbolo)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(color, in: RoundedRectangle(cornerRadius: 10))
            Text(titulo).font(.body)
            Spacer()
            Text("\(numero)")
                .font(.caption).bold()
                .foregroundStyle(.secondary)
        }
    }
}

// Pantalla informativa reutilizable
struct PantallaInformativa: View {
    let titulo: String
    let simbolo: String
    let imagen: String
    let contenido: String

    var body: some View {
        ScrollView{
            VStack(alignment: .leading, spacing: 24) {
                // Foto del tema (pellízcala para hacer zoom)
                FotoSantos(nombre: imagen, simbolo: simbolo)

                Label(titulo, systemImage: simbolo)
                    .font(.title)
                    .bold()
                    .foregroundStyle(Color.verdeOscuro)
                Text(contenido)
                    .font(.body)
                    .lineSpacing(6)
            }
            .padding()
            .padding(.bottom, 80)
        }
        .navigationTitle(titulo)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HistoriaView: View {
    var body: some View {
        PantallaInformativa(
            titulo: "Historia",
            simbolo: "book.closed",
            imagen: "historia",
            contenido:"El Club Santos Laguna fue fundado el 4 de septiembre de 1983 en Torreón, Coahuila, y representa a toda la Comarca Lagunera (Torreón, Gómez Palacio y Lerdo). Es conocido como \"Los Guerreros\" y sus colores son el verde y el blanco.\n\nDurante muchos años jugó en el antiguo Estadio Corona, apodado \"La Casa del Dolor Ajeno\" porque era muy difícil ganarle de visitante. En 2009 se mudó a su casa actual, el Estadio Corona del Territorio Santos Modelo (TSM).")
    }
}

struct TitulosView: View {
    var body: some View {
        PantallaInformativa(
            titulo: "Títulos",
            simbolo: "trophy",
            imagen: "titulos",
            contenido:"CAMPEONATOS DE LIGA (6)\nInvierno 1996\nVerano 2001\nClausura 2008\nClausura 2012\nClausura 2015\nClausura 2018\n\nCOPA MX\nApertura 2014\n\nCAMPEÓN DE CAMPEONES\n2015\n\nCONCACAF\nSubcampeón de la Liga de Campeones de la CONCACAF en dos ocasiones.")
    }
}

struct EstadioView: View {
    private let coordenada = CLLocationCoordinate2D(latitude: 25.629, longitude: -103.379)
    var body: some View {
        ScrollView{
        VStack(alignment: .leading, spacing: 16){
            FotoSantos(nombre: "estadio", simbolo: "building.columns", alto: 200)

            Text("¿Dónde juega el Santos?").font(.title2).bold()
            Text("Estadio Corona (TSM), Torreón, Coahuila. Inaugurado el 11 de noviembre de 2009, con capacidad para unas 30,000 personas.")
                .foregroundStyle(.secondary)

            // interactionModes: [] para que el mapa no "robe" el gesto de deslizar
            Map(
                initialPosition: .region(
                    MKCoordinateRegion(
                        center: coordenada,
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.08,
                            longitudeDelta: 0.08
                        )
                    )
                ),
                interactionModes: []
            ){
                Marker("Estadio Corona",
                       coordinate: coordenada).tint(Color.verdeSantos)
            }
            .frame(height: 260)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
        .padding(.bottom, 80)
        }
        .navigationTitle("Estadio")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct IdolosView: View {
    var body: some View {
        PantallaInformativa(
            titulo: "Ídolos",
            simbolo: "star.fill",
            imagen: "idolos",
            contenido:"JARED BORGETTI\nEl máximo goleador en la historia del club y figura del título de Verano 2001.\n\nORIBE PERALTA\nGoleador lagunero, campeón con Santos en el Clausura 2012.\n\nCHRISTIAN \"CHUCHO\" BENÍTEZ\nDelantero ecuatoriano, campeón y goleador en el Clausura 2008.\n\nLA AFICIÓN\nLa gente de La Laguna es el jugador número 12 de los Guerreros.")
    }
}

// Pantalla de juego: arrastrar, pellizcar y rotar el balón
struct CanchaView: View {
    @State private var posicion: CGSize = .zero
    @State private var posicionFinal: CGSize = .zero
    @State private var escala: CGFloat = 1.0
    @State private var angulo: Angle = .zero
    @State private var goles = 0

    var body: some View {
        VStack(spacing: 16){
            Text("Goles: \(goles)").font(.title).bold()
            Text("Arrastra el balón hacia la portería, pellízcalo para cambiar su tamaño o gíralo con dos dedos. Toca dos veces para reiniciarlo.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            ZStack{
                RoundedRectangle(cornerRadius: 16).fill(Color.verdeSantos)

                // Portería arriba
                VStack{
                    Rectangle()
                        .stroke(.white, lineWidth: 4)
                        .frame(width: 140, height: 50)
                    Spacer()
                }
                .padding(.top, 8)

                Circle().stroke(.white.opacity(0.6), lineWidth: 2).frame(width: 100)

                Image(systemName: "soccerball")
                    .font(.system(size: 50))
                    .foregroundStyle(.black)
                    .background(Circle().fill(.white))
                    .scaleEffect(escala)
                    .rotationEffect(angulo)
                    .offset(posicion)
                    // highPriorityGesture: arrastrar el balón no cambia de pantalla
                    .highPriorityGesture(
                        DragGesture()
                            .onChanged { valor in
                                posicion = CGSize(
                                    width: posicionFinal.width + valor.translation.width,
                                    height: posicionFinal.height + valor.translation.height
                                )
                            }
                            .onEnded { _ in
                                // Si el balón llega a la portería, es gol
                                if posicion.height < -130 && abs(posicion.width) < 70 {
                                    goles += 1
                                    withAnimation(.spring) {
                                        posicion = .zero
                                    }
                                    posicionFinal = .zero
                                } else {
                                    posicionFinal = posicion
                                }
                            }
                    )
                    .simultaneousGesture(
                        MagnifyGesture()
                            .onChanged { valor in
                                escala = min(max(valor.magnification, 0.5), 2.5)
                            }
                    )
                    .simultaneousGesture(
                        RotateGesture()
                            .onChanged { valor in
                                angulo = valor.rotation
                            }
                    )
                    // Doble tap: reinicia el balón
                    .onTapGesture(count: 2){
                        withAnimation(.spring) {
                            posicion = .zero
                            escala = 1.0
                            angulo = .zero
                        }
                        posicionFinal = .zero
                    }
            }
            .frame(height: 380)

            Spacer()
        }
        .padding()
        .padding(.bottom, 60)
        .navigationTitle("Juega con el balón")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
