
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1, define un macro que nos da una queue en el background
#define kLatestKivaLoansURL [NSURL URLWithString:@"http://softv2.trans-tec.mx/ws/cliente.php"] //2, crea un macro llamado kLatestKivaLoansURL, devuelve un NSURL

#import "ViewController.h"

@interface NSDictionary(JSONCategories)
    +(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress;
    -(NSData*)toJSON;
@end

@implementation NSDictionary(JSONCategories)
//Este metodo obtiene un String de la dir web, para trabajar url como texto y no como NSURL, por facilidad
+(NSDictionary*)dictionaryWithContentsOfJSONURLString:(NSString*)urlAddress
{
    NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString: urlAddress] ];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}
//Se llama este metodo dentro de un NSDictionary para obtener un dato JSON de él.
-(NSData*)toJSON
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}
@end


@implementation ViewController
@synthesize humanReadble,jsonSummary;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Descargamos los datos del JSON desde la Web en el background, background thread
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:kLatestKivaLoansURL];
                       [self performSelectorOnMainThread:@selector(fetchedData:) //Cuando NSData termina de buscar datos, llamamos a perfomrSelector. Los elementos UIKit solo pueden ser llamados desde el main thread
                                              withObject:data waitUntilDone:YES];
    });
}

/* Cuando los datos hayan llegado al metodo fetchedData: seran llamados.
   Y la instancia de NSData sera pasada a él. En nuestro caso nuestro archivo JSON es muy pequeño  asi que vamos a parsearlo dentro de fetchedData: en el hilo principal.
   Si se esta pasando JSON largos, se debe hacer en el background. */

/* Opciones para convertir JSON a objetos:
 
    NSJSONReadingMutableContainers:
                    Los arrays y diccionarios creados son mutables. Es bueno si quieres agregar cosas a los contenedores despues de parsearlos.
 
    NSJSONReadingMutableLeaves: 
                    Los valores dentro de los arreglos y diccionarios seran mutables. Es bueno si quieres modificar las cadenas leidas en el.
 
    NSJSONReadignAllowFragments: 
                    Parsea al nivel alto objetos que no son arreglos o diccionarios
 
    kNilOptions es equivalente a 0
*/

- (void)fetchedData:(NSData *)responseData {
   
    //parse out the json data
    NSError* error;
    NSDictionary* datosdelJson = [NSJSONSerialization
                          JSONObjectWithData:responseData       //1
                          options:kNilOptions
                          error:&error];
    
    NSArray* clienteID = [datosdelJson objectForKey:@"153"];    //2
    NSLog(@"datos recuperados: \n %@", clienteID);            //3
    
  //Obtener un dato particular
    NSString *email   = [NSString stringWithFormat:@"%@",[clienteID valueForKey:@"Email"]];
    NSString *empresa = [NSString stringWithFormat:@"%@",[clienteID valueForKey:@"Empresa"]];
    NSString *suid    = [NSString stringWithFormat:@"%@",[clienteID valueForKey:@"Id"]];
    NSString *nombre  = [NSString stringWithFormat:@"%@",[clienteID valueForKey:@"Nombre"]];
    NSString *tipo    = [NSString stringWithFormat:@"%@",[clienteID valueForKey:@"Tipo"]];
    
    NSLog(@"\n Email: %@",email);
    NSLog(@"\n Empresa: %@",empresa);
    NSLog(@"\n ID: %@",suid);
    NSLog(@"\n Nombre: %@",nombre);
    NSLog(@"\n Tipo: %@",tipo);
    
    //***** MENU *****
    
    //NSDictionary *menuAvisos = [(NSDictionary*)[clienteID valueForKey:@"153"]valueForKey:@"menu"];
   /* NSDictionary* menu = [[datosdelJson objectForKey:@"153"]objectForKey:@"menu"];
    NSString *menuavisos = [NSString stringWithFormat:@"%@",[menu valueForKey:@"Avisos"]];
    NSLog(@"\n menu: %@",menuavisos);  */
    
        //Obtener todas las llaves del menu
        NSDictionary *menu = [(NSDictionary*)[datosdelJson objectForKey:@"153"] objectForKey:@"menu"];
        NSLog(@"\n menu keys: %@",[menu allKeys]);
    
        //Mostrar los valores de las llaves
        NSString *reportes  = [NSString stringWithFormat:@"%@",[menu valueForKey:@"Reportes"]];
        NSString *avisos    = [NSString stringWithFormat:@"%@",[menu valueForKey:@"Avisos"]];
        NSString *logistica = [NSString stringWithFormat:@"%@",[menu valueForKey:@"Logistica"]];

        NSLog(@"\n Reportes %@ \n Avisos %@ \n Logistica %@ \n", reportes, avisos, logistica);
    
            //----> para menu reportes
            NSDictionary *menuReportes  = [[(NSDictionary*)[datosdelJson objectForKey:@"153"] objectForKey:@"menu"] objectForKey:@"Reportes"];
            NSLog(@"\n menu reportes keys: %@",[menuReportes allKeys]); //obtenemos sus keys
    
                NSString *egresos       = [NSString stringWithFormat:@"%@",[menuReportes valueForKey:@"egresos"]];
                NSString *flujo         = [NSString stringWithFormat:@"%@",[menuReportes valueForKey:@"flujo"]];
                NSString *ingresos      = [NSString stringWithFormat:@"%@",[menuReportes valueForKey:@"ingresos"]];
                NSString *rentabilidad  = [NSString stringWithFormat:@"%@",[menuReportes valueForKey:@"rentabilidad"]];
                NSLog(@"\n *** Menu Reportes *** \n egresos:%@ \n flujo:%@ \n ingresos: %@ \n rentabilidad: %@",egresos,flujo,ingresos,rentabilidad); //obtenemos su valor
    
            //----> para menu Avisos
            NSDictionary *menuAvisos  = [[(NSDictionary*)[datosdelJson objectForKey:@"153"] objectForKey:@"menu"] objectForKey:@"Avisos"];
            NSLog(@"\n menu avisos keys: %@",[menuAvisos allKeys]); //obtenemos sus keys
    
                NSString *losavisos = [NSString stringWithFormat:@"%@",[menuAvisos valueForKey:@"avisos"]];
                NSLog(@"\n *** Menu Avisos *** \n avisos:%@ ",losavisos); //obtenemos su valor
    
            //----> para menu Logistica
            NSDictionary *menuLogistica  = [[(NSDictionary*)[datosdelJson objectForKey:@"153"] objectForKey:@"menu"] objectForKey:@"Logistica"];
            NSLog(@"\n menu avisos keys: %@",[menuAvisos allKeys]); //obtenemos sus keys
    
            NSString *altacp    = [NSString stringWithFormat:@"%@",[menuLogistica valueForKey:@"altacp"]];
            NSString *altaviaje = [NSString stringWithFormat:@"%@",[menuLogistica valueForKey:@"altaviaje"]];
            NSString *entregas  = [NSString stringWithFormat:@"%@",[menuLogistica valueForKey:@"entregas"]];
            NSString *gastos    = [NSString stringWithFormat:@"%@",[menuLogistica valueForKey:@"gastos"]];
    
            NSLog(@"\n *** Menu Logistica *** \n altacp:%@ \n altaviaje:%@ \n entregas:%@ \n gastos:%@ ",altacp,altaviaje,entregas,gastos); //obtenemos su valor
}

@end


