part of drails_di;

final _appContextlog = new Logger('application_context');

const CONTROLLER_NAMES = const ['Controller'];
const COMPONENT_NAMES = const ['Service', 'Repository'];

class ApplicationContext {
  static Map<Type, Object> components = {};

  /**
   * Get the controllers from the application Context
   */
  static Iterable<Object> get controllers {
    return components.values.where((component) => CONTROLLER_NAMES.any((name) => 
        MirrorSystem.getName(reflect(component).type.simpleName).endsWith(name))
       );
  }

  /**
   * Initialize the application Context
   */
  static void bootstrap(List<Symbol> includedLibs) {
    
    var dms = [];
    includedLibs.forEach((inclibrary) {
      var libs = currentMirrorSystem().findLibrary(inclibrary).declarations.values.where((dm) => dm is ClassMirror);
      dms.addAll(libs);
    });
       
    var componentDms = dms.where((dm) => 
        !dm.isAbstract
        && COMPONENT_NAMES.any((name) => 
            MirrorSystem.getName(dm.simpleName).endsWith(name)));
    
    dms.where((dm) => 
      !dm.isAbstract
      && CONTROLLER_NAMES.any((name) => MirrorSystem.getName(dm.simpleName).endsWith(name))
    ).forEach((ClassMirror cm) => components[cm.reflectedType] = cm.newInstance(const Symbol(''), []).reflectee );
    
    dms.where((dm) => 
      dm.isAbstract
      && MirrorSystem.getName(dm.simpleName).endsWith('Service')
    ).forEach((ClassMirror injectableCm) =>
      components[injectableCm.reflectedType] = getObjectThatExtend(injectableCm, dms));
    
    _appContextlog.fine('components: $components');
    
    _injectComponents();
  }
  
  static void _injectComponents() {
    controllers.forEach((controller) {
      var im = reflect(controller);
      
      new GetVariablesAnnotatedWith<_Autowired>().from(im).forEach((vm) {
        print(vm.type);
        var injectable = components[vm.type.reflectedType];
        im.setField(vm.simpleName, injectable);
      });
    });
  }
  
}
