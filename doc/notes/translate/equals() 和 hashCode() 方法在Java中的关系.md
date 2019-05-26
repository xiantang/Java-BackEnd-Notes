Java.lang.object 定义了两个非常重要的方法:

* public boolean equals(Object obj)
* public int hashCode()


## equals() 方法

在Java 中 equals()是用来比较两个对象是否相等。主要分为两个方面的比较:

* **浅比较(Shallow comparison)**:在Java.lang.Object 类中默认的实现是简单的比较两个引用(假设是x和y)是否指向同样的对象。由于Object类没有定义其状态的数据成员，所以也称之为浅比较(Shallow comparison)。
* **深比较(Deep Comparison)**:假设一个类提供了拥有对equals()方法的自己的实现，目的去比较具有w.r.t状态的对象。意思是对象中的数据成员(例如:域)将会被比较。基于数据成员的比较方式叫做深比较(Deep Comparison)。

语法:

```
public boolean equals  (Object obj)

// This method checks if some other Object
// passed to it as an argument is equal to 
// the Object on which it is invoked.
//此方法检查是否有其他Object
//作为参数传递给它等于
//调用它的Object。
```


**Object类中一些关于equals()的原则**:如果某个其他对象等于给定对象，则它遵循以下规则：

* 自反性：对于任何引用a,`a.equals(a)`应该返回true。
* 对称性：对于任何引用a和b，如果`a.equals(b)`返回true,那么`b.equals(a)`必须返回true。
* 传递性:对于任何引用a，b和c，如果`a.equals(b)`返回true，　并且`b.equals(c)`返回true，则`a.equals(c)`应该返回true。
* 一致性:对于任何应用a和b,多次调用`a.equals(b)`始终返回true或始终返回false,前提是在没有修改对象`equals`比较中使用的信息。

注:对于任何非空的引用a,` a.equals(null) `应该返回false。

 
```Java
class Geek  
{ 
      
    public String name; 
    public int id; 
          
    Geek(String name, int id)  
    { 
              
        this.name = name; 
        this.id = id; 
    } 
      
    @Override
    public boolean equals(Object obj) 
    { 
    // 是否引用都指向同一个对象  
    // checking if both the object references are  
    // referring to the same object. 
    if(this == obj) 
            return true; 
        // 比较当前对象和传入的参数的类对象是否相同
        // it checks if the argument is of the  
        // type Geek by comparing the classes  
        // of the passed argument and this object. 
        // if(!(obj instanceof Geek)) return false; ---> avoid. 
        if(obj == null || obj.getClass()!= this.getClass()) 
            return false; 
        // 向下转型
        // type casting of the argument.  
        Geek geek = (Geek) obj; 
        
        // 比较成员变量
        // comparing the state of argument with  
        // the state of 'this' Object. 
        return (geek.name == this.name && geek.id == this.id); 
    } 
      
    @Override
    public int hashCode() 
    { 
        // 我们返回Geek_id作为hashcode
        // 我们可以计算或者使用对象内存地址的值
        // 这取决于你如何实现hashCode（）方法。
        // We are returning the Geek_id  
        // as a hashcode value. 
        // we can also return some  
        // other calculated value or may 
        // be memory address of the  
        // Object on which it is invoked.  
        // it depends on how you implement  
        // hashCode() method. 
        return this.id; 
    } 
      
} 

//Driver code 
class GFG 
{ 
      
    public static void main (String[] args) 
    { 
         
        // creating the Objects of Geek class. 
        Geek g1 = new Geek("aa", 1); 
        Geek g2 = new Geek("aa", 1); 
        // 比较上面创建的对象
        // comparing above created Objects. 
        if(g1.hashCode() == g2.hashCode()) 
        { 
  
            if(g1.equals(g2)) 
                System.out.println("Both Objects are equal. "); 
            else
                System.out.println("Both Objects are not equal. "); 
      
        } 
        else
        System.out.println("Both Objects are not equal. ");  
    }  
} 

```

输出:
```
Both Objects are equal.
```

首先我们比较hashCode在两个对象上(g1和g2)如果hashCode产生自两个对象并不意味着这两个对象相同，两个不同的对象的hashCode也是可以相同的。而且，如果他们拥有相同的id(在这种情况下)。那么我们将比较这两个对象w.r.t的状态。如果两个对象具有相同的状态，则他们相等，否则不相等。

在上面的例子中看到这一行：

```
// if(!(obj instanceof Geek)) return false;--> avoid.-->(a)
```

我们使用下面一行来代替上面这一行:
```java
if(obj == null || obj.getClass()!= this.getClass()) return false; --->(y)
```

原因:引用obj也可以引用Geek对象的子类，在Line(b)中传入的对象是Geek的子类的对象的话，就会返回false，但是在Line(a)中却会返回true。

## hashCode() method


它将哈希码值作为整数返回。 Hashcode值主要用于基于散列的集合，如`HashMap`，`HashSet`，`HashTable` ... .etc。必须在覆盖`equals（）`方法的每个类中重写此方法。

语法:

```java
public int hashCode()

// This method returns the hash code value 
// for the object on which this method is invoked.
// 当这个方法被调用时候返回hashcode
```

**普遍的hashCode规定有**:
* 在代码的运行期时，多次调用hashCode()在同一个对象然后必须返回一致的整数值。如果对象没有在`equals(ojb)`比较中有成员变量被修改，调用后返回的值都一致。
* 如果两个对象相等，则根据`equals（Object）`方法，`hashCode（）`方法必须在两个对象中的每一个上生成相同的Integer。
* 如果两个对象不相等，则根据`equals（Object）`方法，`hashCode（）`方法在两个对象中的每一个上生成的Integer值不必是不同的。它可以是相同的，但是对于两个不同的对象，通过hashCode产生不同的值对于提高基于散列的集合（如HashMap，HashTable等）的性能会更好。

